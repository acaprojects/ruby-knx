# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    # APCI type
    ActionType = {
        group_read:  0,
        group_resp:  1,
        group_write: 2,

        individual_write: 0x0C0,
        individual_read:  0x100,
        individual_resp:  0x140,

        adc_read: 6,
        adc_resp: 0x1C0,

        sys_net_param_read: 0x1C4,
        sys_net_param_resp: 0x1C9,
        sys_net_param_write: 0x1CA,

        memory_read:  0x020,
        memory_resp:  0x024,
        memory_write: 0x028,

        user_memory_read: 0x2C0,
        user_memory_resp: 0x2C1,
        user_memory_write: 0x2C2,

        user_manufacturer_info_read: 0x2C5,
        user_manufacturer_info_resp: 0x2C6,

        function_property_command: 0x2C7,
        function_property_state_read: 0x2C8,
        function_property_state_resp: 0x2C9,

        device_descriptor_read: 0x300,
        device_descriptor_resp: 0x340,

        restart: 0x380,
        escape: 0x3C0,  # Not sure about this one

        authorize_request: 0x3D1,
        authorize_resp: 0x3D2,

        key_write: 0x3D3,
        key_resp: 0x3D4,

        property_value_read: 0x3D5,
        property_value_resp: 0x3D6,
        property_value_write: 0x3D7,

        property_description_read: 0x3D8,
        property_description_resp: 0x3D9,

        network_param_read: 0x3DA,
        network_param_resp: 0x3DB,

        individual_serial_num_read:  0x3DC,
        individual_serial_num_resp:  0x3DD,
        individual_serial_num_write: 0x3DF,

        domain_write: 0x3E0,
        domain_read: 0x3E1,
        domain_resp: 0x3E2,
        domain_selective_read: 0x3E3,

        network_param_write: 0x3E4,

        link_read: 0x3E5,
        link_resp: 0x3E6,
        link_write: 0x3E7,

        group_prop_value_read: 0x3E8,
        group_prop_value_resp: 0x3E9,
        group_prop_value_write: 0x3EA,
        group_prop_value_info: 0x3EB,

        domain_serial_num_read:  0x3EC,
        domain_serial_num_resp:  0x3ED,
        domain_serial_num_write: 0x3EE,

        filesystem_info: 0x3F0
    }
    ActionType.merge!(ActionType.invert)

    TpciType = {
        unnumbered_data: 0b00,
        numbered_data:   0b01,
        unnumbered_control: 0b10,
        numbered_control:   0b11
    }

    MsgCode = {
        raw_request: 0x10,
        data_request: 0x11,
        poll_data_request: 0x13,
        poll_data_connection: 0x25,
        data_indicator: 0x29,
        busmon_indicator: 0x2B,
        raw_indicator: 0x2D,
        data_connection: 0x2E,
        raw_connection: 0x2F,
        data_connection_request: 0x41,
        data_individual_request: 0x4A,
        data_connection_indicator: 0x89,
        data_individual_indicator: 0x94,
        reset_indicator: 0xF0,
        reset_request: 0xF1,
        propwrite_connection: 0xF5,
        propwrite_request: 0xF6,
        propinfo_indicator: 0xF7,
        func_prop_com_request: 0xF8,
        func_prop_stat_read_request: 0xF9,
        func_prop_com_connection: 0xFA,
        prop_read_connection: 0xFB,
        prop_read_request: 0xFC
    }

    Priority = {
        system: 0,
        alarm: 1,
        high: 2,
        low: 3
    }

    ErrorCodes = {
        0x00 => "Unspecified Error",
        0x01 => "Out of range",
        0x02 => "Out of maxrange",
        0x03 => "Out of minrange",
        0x04 => "Memory Error",
        0x05 => "Read only",
        0x06 => "Illegal command",
        0x07 => "Void DP",
        0x08 => "Type conflict",
        0x09 => "Prop. Index range error",
        0x0A => "Value temporarily not writeable"
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


        # Applies 2 byte APCI value where required
        #
        # @param val [Symbol, Fixnum, Integer] the value or symbol representing the APCI value
        # @return [true, false] returns true if data is available for storage
        def apply_apci(val, data = nil)
            value = if val.is_a?(Symbol)
                ActionType[val]
            else
                val
            end

            if value > 15
                self.apci = (value >> 6) & 0b1111
                self.data = value & 0b111111
                false
            else
                self.apci = value
                if data && data[0] && data[0] <= 0b111111
                    self.data = data[0]
                    true
                else
                    self.data = 0
                    false
                end
            end
        rescue => e
            raise ArgumentError, "Bad apci value: #{data}"
        end
    end
end
