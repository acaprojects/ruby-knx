#encoding: ASCII-8BIT

require 'knx'


describe "knx protocol helper" do
    before :each do
        @knx = KNX.new
    end

    it "should parse and generate the same string" do
        datagram = @knx.read("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x80")
        expect(datagram.to_binary_s).to eq("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x80")

        datagram = @knx.read("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x81")
        expect(datagram.to_binary_s).to eq("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x81")

        expect(datagram.data).to eq([1])
        expect(datagram.source_address.to_s).to eq("0.0.1")
        expect(datagram.destination_address.to_s).to eq("1/2/0")
    end

    it "should generate single bit action requests" do
        datagram = @knx.action('1/2/0', false)
        expect(datagram.to_binary_s).to eq("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x80")

        datagram = @knx.action('1/2/0', true)
        expect(datagram.to_binary_s).to eq("\x06\x10\x05\x30\0\x11\x29\0\xbc\xe0\0\x01\x0a\0\x01\0\x81")
    end

    it "should generate byte action requests" do
        datagram = @knx.action('1/2/0', 20)
        expect(datagram.to_binary_s).to eq("\x06\x10\x050\x00\x11)\x00\xBC\xE0\x00\x01\n\x00\x01\x00\x94")

        datagram = @knx.action('1/2/0', 240)
        expect(datagram.to_binary_s).to eq("\x06\x10\x050\x00\x12)\x00\xBC\xE0\x00\x01\n\x00\x01\x00\x80\xF0")
    end
end
