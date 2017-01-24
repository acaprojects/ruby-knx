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
        remote_reset_request: 0x0743,

        # This wraps a regular KNX frame
        secure_wrapper: 0x0950,

        # KNXnet/IP services (tunneling)
        secure_session_request: 0x0951,
        secure_session_response: 0x0952,
        secure_session_authenticate: 0x0953,
        secure_session_status: 0x0954,
        secure_timer_notify: 0x0955
    }

    # http://www.openremote.org/display/forums/KNX+IP+Connection+Headers
    class Header < BinData::Record
        endian :big

        uint8  :header_length,  value: 0x06  # Length 6 (always for version 1)
        uint8  :version
        uint16 :request_type
        uint16 :request_length

        # See: https://youtu.be/UjOBudAG654?t=42m20s
        struct :wrapper, onlyif: -> { request_type == RequestTypes[:secure_wrapper] } do
            uint16 :session_id          # Not sure what this should be
            bit48  :timestamp           # Timestamp for multicast messages, sequence number for tunneling
            bit48  :knx_serial_number   # Serial of the device - random constant
            uint16 :message_tag         # Random number

            # header + security info + cbc_mac == 38
            #   6          16            16    == 38
            string :encrypted_frame, length: -> { request_length - 38 }
            # Encryption: Timestamp + Serial Number + Tag + 0x01 + counter (1 byte), starting at 0
            # Single key for each multicast group: PID_BACKBONE_KEY
            # https://en.wikipedia.org/wiki/CCM_mode

            # https://en.wikipedia.org/wiki/CBC-MAC (always 128bit (16bytes) in KNX)
            # Timestamp + Serial Number + Tag + frame length (2 bytes)
            string :cmac, length: 16
        end

        struct :timer, onlyif: -> { request_type == RequestTypes[:secure_timer_notify] } do
            bit48  :timestamp           # Current time as understood by the device
            bit48  :knx_serial_number   # Serial of the device
            uint16 :message_tag         # Random number

            # Timestamp + Serial Number + Tag + frame length (2 bytes) == 0x0000
            string :cmac, length: 16
        end
    end
end
