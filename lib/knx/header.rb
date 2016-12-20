# frozen_string_literal: true, encoding: ASCII-8BIT

class KNX
    RequestTypes = {
        search_request: 0x0201,
        search_response: 0x0202,
        description_request: 0x0203,
        description_response: 0x0204,
        connect_request: 0x0205,
        connect_response: 0x0206,
        connectionstate_request: 0x0207,
        connectionstate_response: 0x0208,
        disconnect_request: 0x0209,
        disconnect_response: 0x020A,
        device_configuration_request: 0x0310,
        device_configuration_ack: 0x0311,
        tunnelling_request: 0x0420,
        tunnelling_ack: 0x0421,
        routing_indication: 0x0530,
        routing_lost_message: 0x0531,

        routing_busy: 0x0532,
        remote_diagnostic_request: 0x0740,
        remote_diagnostic_response: 0x0741,
        remote_basic_config_request: 0x0742,
        remote_reset_request: 0x0743
    }

    # http://www.openremote.org/display/forums/KNX+IP+Connection+Headers
    class Header < BinData::Record
        endian :big

        uint8  :header_length,  value: 0x06  # Length 6 (always for version 1)
        uint8  :version
        uint16 :request_type
        uint16 :request_length
    end
end
