/*
 * @(#)ThinkGearStreamParser.c    2.0    Mar 04, 2008
 *
 * Copyright (c) 2008 NeuroSky, Inc. All Rights Reserved
 * NEUROSKY PROPRIETARY/CONFIDENTIAL. Use is subject to license terms.
 */

/**
 * @file ThinkGearStreamParser.c
 *
 * @author Kelvin Soo
 * @version 2.0 Mar 04, 2008 Kelvin Soo
 *   - Renamed to ThinkGearStreamParser from ThinkGearStreamDecoder.
 *   - Revised to call a callback function instead of stuffing arriving
 *     data values into a ThinkGearData object.
 *   - Renamed symbols according to updated Packet vocabulary.
 * @version 1.0 Nov 27, 2007 Kelvin Soo
 *   - Initial version (ThinkGearStreamDecoder).
 */

#include "ThinkGearStreamParser.h"

/* Include libraries required specifically by this implementation of this
 * library and not already included by this library's header
 */
#include <stdio.h>

/* Decoder states (Packet decoding) */
#define PARSER_STATE_NULL           0x00  /* NULL state */
#define PARSER_STATE_SYNC           0x01  /* Waiting for SYNC byte */
#define PARSER_STATE_SYNC_CHECK     0x02  /* Waiting for second SYNC byte */
#define PARSER_STATE_PAYLOAD_LENGTH 0x03  /* Waiting for payload[] length */
#define PARSER_STATE_PAYLOAD        0x04  /* Waiting for next payload[] byte */
#define PARSER_STATE_CHKSUM         0x05  /* Waiting for chksum byte */

/* Decoder states (2-byte raw decoding) */
#define PARSER_STATE_WAIT_HIGH      0x06  /* Waiting for high byte */
#define PARSER_STATE_WAIT_LOW       0x07  /* High r'cvd.  Expecting low part */

/* Other constants */
#define PARSER_SYNC_BYTE            0xAA  /* Syncronization byte */
#define PARSER_EXCODE_BYTE          0x55  /* EXtended CODE level byte */

/* Declare private function prototypes */
int
parsePacketPayload( ThinkGearStreamParser *parser );
int
parseDataRow( ThinkGearStreamParser *parser, unsigned char *rowPtr );

/*
 * See header file for interface documentation.
 */
int
THINKGEAR_initParser( ThinkGearStreamParser *parser,
                      unsigned char parserType,
                      void (*handleDataValueFunc)(
                          unsigned char extendedCodeLevel,
                          unsigned char code, unsigned char numBytes,
                          const unsigned char *value, void *customData),
                      void *customData ) {

    if( !parser ) return( -1 );

    /* Initialize the parser's state based on the parser type */
    switch( parserType ) {
        case( PARSER_TYPE_PACKETS ):
            parser->state = PARSER_STATE_SYNC;
            break;
        case( PARSER_TYPE_2BYTERAW ):
            parser->state = PARSER_STATE_WAIT_HIGH;
            break;
        default: return( -2 );
    }

    /* Save parser type */
    parser->type = parserType;

    /* Save user-defined handler function and data pointer */
    parser->handleDataValue = handleDataValueFunc;
    parser->customData = customData;

    return( 0 );
}

/*
 * See header file for interface documentation.
 */
int
THINKGEAR_parseByte( ThinkGearStreamParser *parser, unsigned char byte ) {

    int returnValue = 0;

    if( !parser ) return( -1 );

    /* Pick handling according to current state... */
    switch( parser->state ) {

        /* Waiting for SyncByte */
        case( PARSER_STATE_SYNC ):
            if( byte == PARSER_SYNC_BYTE ) {
                parser->state = PARSER_STATE_SYNC_CHECK;
            }
            break;

        /* Waiting for second SyncByte */
        case( PARSER_STATE_SYNC_CHECK ):
            if( byte == PARSER_SYNC_BYTE ) {
                parser->state = PARSER_STATE_PAYLOAD_LENGTH;
            } else {
                parser->state = PARSER_STATE_SYNC;
            }
            break;

        /* Waiting for Data[] length */
        case( PARSER_STATE_PAYLOAD_LENGTH ):
            parser->payloadLength = byte;
            if( parser->payloadLength > 170 ) {
                parser->state = PARSER_STATE_SYNC;
                returnValue = -3;
            } else if( parser->payloadLength == 170 ) {
                returnValue = -4;
            } else {
                parser->payloadBytesReceived = 0;
                parser->payloadSum = 0;
                parser->state = PARSER_STATE_PAYLOAD;
            }
            break;

        /* Waiting for Payload[] bytes */
        case( PARSER_STATE_PAYLOAD ):
            parser->payload[parser->payloadBytesReceived++] = byte;
            parser->payloadSum = (unsigned char)(parser->payloadSum + byte);
            if( parser->payloadBytesReceived >= parser->payloadLength ) {
                parser->state = PARSER_STATE_CHKSUM;
            }
            break;

        /* Waiting for CKSUM byte */
        case( PARSER_STATE_CHKSUM ):
            parser->chksum = byte;
            parser->state = PARSER_STATE_SYNC;
            if( parser->chksum != ((~parser->payloadSum)&0xFF) ) {
                returnValue = -2;
            } else {
                returnValue = 1;
                parsePacketPayload( parser );
            }
            break;

        /* Waiting for high byte of 2-byte raw value */
        case( PARSER_STATE_WAIT_HIGH ):

            /* Check if current byte is a high byte */
            if( (byte & 0xC0) == 0x80 ) {
                /* High byte recognized, will be saved as parser->lastByte */
                parser->state = PARSER_STATE_WAIT_LOW;
            }
            break;

        /* Waiting for low byte of 2-byte raw value */
        case( PARSER_STATE_WAIT_LOW ):

            /* Check if current byte is a valid low byte */
            if( (byte & 0xC0) == 0x40 ) {

                /* Stuff the high and low part of the raw value into an array */
                parser->payload[0] = parser->lastByte;
                parser->payload[1] = byte;

                /* Notify the handler function of received raw value */
                if( parser->handleDataValue ) {
                    parser->handleDataValue( 0, PARSER_CODE_RAW_SIGNAL, 2,
                                             parser->payload,
                                             parser->customData );
                }

                returnValue = 1;
            }

            /* Return to start state waiting for high */
            parser->state = PARSER_STATE_WAIT_HIGH;

            break;

        /* unrecognized state */
        default:
            parser->state = PARSER_STATE_SYNC;
            returnValue = -5;
            break;
    }

    /* Save current byte */
    parser->lastByte = byte;

    return( returnValue );
}

/**
 * Parses each row of data from the @c packet's Data[] block,
 * updating the fields of @c data as appropriate.
 */
int
parsePacketPayload( ThinkGearStreamParser *parser ) {

    unsigned char i = 0;
    unsigned char extendedCodeLevel = 0;
    unsigned char code = 0;
    unsigned char numBytes = 0;

    /* Parse all bytes from the payload[] */
    while( i < parser->payloadLength ) {

        /* Parse possible EXtended CODE bytes */
        while( parser->payload[i] == PARSER_EXCODE_BYTE ) {
            extendedCodeLevel++;
            i++;
        }

        /* Parse CODE */
        code = parser->payload[i++];

        /* Parse value length */
        if( code >= 0x80 ) numBytes = parser->payload[i++];
        else               numBytes = 1;

        /* Call the callback function to handle the DataRow value */
        if( parser->handleDataValue ) {
            parser->handleDataValue( extendedCodeLevel, code, numBytes,
                                     parser->payload+i, parser->customData );
        }
        i = (unsigned char)(i + numBytes);
    }

    return( 0 );
}
