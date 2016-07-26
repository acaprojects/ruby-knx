#encoding: ASCII-8BIT

class KNX
    # APCI type
    ActionType = {
        group_read:  0,
        group_resp:  1,
        group_write: 2,

        individual_write: 3,
        individual_read:  4,
        individual_resp:  5,

        adc_read: 6,
        adc_resp: 7,

        memory_read:  8,
        memory_resp:  9,
        memory_write: 10,

        user_msg: 11,

        descriptor_read: 12,
        descriptor_resp: 13,

        restart: 14,
        escape:  15
    }

    TpciType = {
        unnumbered_data: 0b00,
        numbered_data:   0b01,
        unnumbered_control: 0b10,
        numbered_control:   0b11
    }

    MsgCode = {
        send_datagram: 0x29
    }

    Priority = {
        system: 0,
        alarm: 1,
        high: 2,
        low: 3
    }
    

    # CEMI == Common External Message Interface
    # +--------+--------+--------+--------+----------------+----------------+--------+----------------+
    # |  Msg   |Add.Info| Ctrl 1 | Ctrl 2 | Source Address | Dest. Address  |  Data  |      APDU      |
    # | Code   | Length |        |        |                |                | Length |                |
    # +--------+--------+--------+--------+----------------+----------------+--------+----------------+
    #   1 byte   1 byte   1 byte   1 byte      2 bytes          2 bytes       1 byte      2 bytes
    #
    #  Message Code    = 0x11 - a L_Data.req primitive
    #      COMMON EMI MESSAGE CODES FOR DATA LINK LAYER PRIMITIVES
    #          FROM NETWORK LAYER TO DATA LINK LAYER
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          | Data Link Layer Primitive | Message Code | Data Link Layer Service | Service Description | Common EMI Frame |
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          |        L_Raw.req          |    0x10      |                         |                     |                  |
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          |                           |              |                         | Primitive used for  | Sample Common    |
    #          |        L_Data.req         |    0x11      |      Data Service       | transmitting a data | EMI frame        |
    #          |                           |              |                         | frame               |                  |
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          |        L_Poll_Data.req    |    0x13      |    Poll Data Service    |                     |                  |
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          |        L_Raw.req          |    0x10      |                         |                     |                  |
    #          +---------------------------+--------------+-------------------------+---------------------+------------------+
    #          FROM DATA LINK LAYER TO NETWORK LAYER
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          | Data Link Layer Primitive | Message Code | Data Link Layer Service | Service Description |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |        L_Poll_Data.con    |    0x25      |    Poll Data Service    |                     |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |                           |              |                         | Primitive used for  |
    #          |        L_Data.ind         |    0x29      |      Data Service       | receiving a data    |
    #          |                           |              |                         | frame               |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |        L_Busmon.ind       |    0x2B      |   Bus Monitor Service   |                     |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |        L_Raw.ind          |    0x2D      |                         |                     |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |                           |              |                         | Primitive used for  |
    #          |                           |              |                         | local confirmation  |
    #          |        L_Data.con         |    0x2E      |      Data Service       | that a frame was    |
    #          |                           |              |                         | sent (does not mean |
    #          |                           |              |                         | successful receive) |
    #          +---------------------------+--------------+-------------------------+---------------------+
    #          |        L_Raw.con          |    0x2F      |                         |                     |
    #          +---------------------------+--------------+-------------------------+---------------------+

    #  Add.Info Length = 0x00 - no additional info
    #  Control Field 1 = see the bit structure above
    #  Control Field 2 = see the bit structure above
    #  Source Address  = 0x0000 - filled in by router/gateway with its source address which is
    #                    part of the KNX subnet
    #  Dest. Address   = KNX group or individual address (2 byte)
    #  Data Length     = Number of bytes of data in the APDU excluding the TPCI/APCI bits
    #  APDU            = Application Protocol Data Unit - the actual payload including transport
    #                    protocol control information (TPCI), application protocol control
    #                    information (APCI) and data passed as an argument from higher layers of
    #                    the KNX communication stack
    #
    class CEMI < BinData::Record
        endian :big
        
        uint8 :msg_code
        uint8 :info_length


        # ---------------------
        #    Control Fields
        # ---------------------

        # Bit order
        # +---+---+---+---+---+---+---+---+
        # | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
        # +---+---+---+---+---+---+---+---+

        #  Control Field 1

        #   Bit  |
        #  ------+---------------------------------------------------------------
        #    7   | Frame Type  - 0x0 for extended frame
        #        |               0x1 for standard frame
        #  ------+---------------------------------------------------------------
        #    6   | Reserved
        #        |
        #  ------+---------------------------------------------------------------
        #    5   | Repeat Flag - 0x0 repeat frame on medium in case of an error
        #        |               0x1 do not repeat
        #  ------+---------------------------------------------------------------
        #    4   | System Broadcast - 0x0 system broadcast
        #        |                    0x1 broadcast
        #  ------+---------------------------------------------------------------
        #    3   | Priority    - 0x0 system
        #        |               0x1 normal (also called alarm priority)
        #  ------+               0x2 urgent (also called high priority)
        #    2   |               0x3 low
        #        |
        #  ------+---------------------------------------------------------------
        #    1   | Acknowledge Request - 0x0 no ACK requested
        #        | (L_Data.req)          0x1 ACK requested
        #  ------+---------------------------------------------------------------
        #    0   | Confirm      - 0x0 no error
        #        | (L_Data.con) - 0x1 error
        #  ------+---------------------------------------------------------------
        bit1  :is_standard_frame
        bit1  :_reserved_,   value: 0
        bit1  :no_repeat
        bit1  :broadcast
        bit2  :priority     # 2 bits
        bit1  :ack_requested
        bit1  :is_error

        #  Control Field 2

        #   Bit  |
        #  ------+---------------------------------------------------------------
        #    7   | Destination Address Type - 0x0 individual address
        #        |                          - 0x1 group address
        #  ------+---------------------------------------------------------------
        #   6-4  | Hop Count (0-7)
        #  ------+---------------------------------------------------------------
        #   3-0  | Extended Frame Format - 0x0 standard frame
        #  ------+---------------------------------------------------------------
        bit1  :is_group_address
        bit3  :hop_count
        bit4  :extended_frame_format

        uint16 :source_address
        uint16 :destination_address

        uint8 :data_length


        # In the Common EMI frame, the APDU payload is defined as follows:

        # +--------+--------+--------+--------+--------+
        # | TPCI + | APCI + |  Data  |  Data  |  Data  |
        # |  APCI  |  Data  |        |        |        |
        # +--------+--------+--------+--------+--------+
        #   byte 1   byte 2  byte 3     ...     byte 16

        # For data that is 6 bits or less in length, only the first two bytes are used in a Common EMI
        # frame. Common EMI frame also carries the information of the expected length of the Protocol
        # Data Unit (PDU). Data payload can be at most 14 bytes long.  <p>

        # The first byte is a combination of transport layer control information (TPCI) and application
        # layer control information (APCI). First 6 bits are dedicated for TPCI while the two least
        # significant bits of first byte hold the two most significant bits of APCI field, as follows:

        #   Bit 1    Bit 2    Bit 3    Bit 4    Bit 5    Bit 6    Bit 7    Bit 8      Bit 1   Bit 2
        # +--------+--------+--------+--------+--------+--------+--------+--------++--------+----....
        # |        |        |        |        |        |        |        |        ||        |
        # |  TPCI  |  TPCI  |  TPCI  |  TPCI  |  TPCI  |  TPCI  | APCI   |  APCI  ||  APCI  |
        # |        |        |        |        |        |        |(bit 1) |(bit 2) ||(bit 3) |
        # +--------+--------+--------+--------+--------+--------+--------+--------++--------+----....
        # +                            B  Y  T  E    1                            ||       B Y T E  2
        # +-----------------------------------------------------------------------++-------------....

        # Total number of APCI control bits can be either 4 or 10. The second byte bit structure is as follows:

        #   Bit 1    Bit 2    Bit 3    Bit 4    Bit 5    Bit 6    Bit 7    Bit 8      Bit 1   Bit 2
        # +--------+--------+--------+--------+--------+--------+--------+--------++--------+----....
        # |        |        |        |        |        |        |        |        ||        |
        # |  APCI  |  APCI  | APCI/  |  APCI/ |  APCI/ |  APCI/ | APCI/  |  APCI/ ||  Data  |  Data
        # |(bit 3) |(bit 4) | Data   |  Data  |  Data  |  Data  | Data   |  Data  ||        |
        # +--------+--------+--------+--------+--------+--------+--------+--------++--------+----....
        # +                            B  Y  T  E    2                            ||       B Y T E  3
        # +-----------------------------------------------------------------------++-------------....
        bit2 :tpci # transport protocol control information
        bit4 :tpci_seq_num # Sequence number when tpci is sequenced
        bit4 :apci # application protocol control information (What we trying to do: Read, write, respond etc)
        bit6 :data # Or the tail end of APCI depending on the message type
    end
end
