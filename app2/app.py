#!bin/python3


import asyncio
import collections
import socket
import struct


PP_V2_SIGNATURE = b'\r\n\r\n\x00\r\nQUIT\n'

PP_V2_COMMANDS = {
    b'\x00': 'LOCAL',
    b'\x01': 'PROXY',
}

PP_V2_VERSIONS = {
    b'\x02': '2',
}

PP_V2_ADDRESS_FAMILIES = {
    b'\x00': 'AF_UNSPEC',
    b'\x01': 'AF_INET',
    b'\x02': 'AF_INET6',
    b'\x03': 'AF_UNIX',
}

PP_V2_PROTOCOLS = {
    b'\x00': 'UNSPEC',
    b'\x01': 'STREAM',
    b'\x02': 'DGRAM',
}

PP_V2_ADDRESS_FORMATS = {
    'AF_INET': '4B4BHH',
    'AF_INET6': '16B16BHH',
    'AF_UNIX': '108B108B',
}

ProxyProtocolV2Header = collections.namedtuple('ProxyProtocolV2Header', [
    'version',
    'command',
    'protocol',
    'address_family',
    'address',
])

ProxyProtocolIpAddress = collections.namedtuple('ProxyProtocolIpAddress', [
    'source_ip',
    'source_port',
    'dest_ip',
    'dest_port',
])


async def proxy_protocol_header_recv(loop, sock):
    # The header, itself has a header
    header_format = '>12sccH'
    header_length = 16

    header_raw = await recv_num_bytes(loop, sock, header_length)
    header_unpacked = struct.unpack(header_format, header_raw)

    signature = header_unpacked[0]
    version_and_command = header_unpacked[1][0]
    protocol_and_address_family = header_unpacked[2][0]
    address_length = header_unpacked[3]

    if signature != PP_V2_SIGNATURE:
        raise Exception('Incorrect proxy protocol signature')

    version = PP_V2_VERSIONS[bytes([version_and_command >> 4])]
    command = PP_V2_COMMANDS[bytes([version_and_command & 0x0f])]

    protocol = PP_V2_PROTOCOLS[bytes([protocol_and_address_family & 0x0f])]
    address_family = PP_V2_ADDRESS_FAMILIES[bytes([protocol_and_address_family >> 4])]

    address_raw = await recv_num_bytes(loop, sock, address_length)

    address_format = PP_V2_ADDRESS_FORMATS[address_family]
    address = struct.unpack(address_format, address_raw[:struct.calcsize(address_format)])

    return ProxyProtocolV2Header(
        version=version,
        command=command,
        protocol=protocol,
        address_family=address_family,
        # For IPV6/Unix, you'll need to do something else
        address=ProxyProtocolIpAddress(
            source_ip='.'.join(str(part) for part in address[:4]),
            source_port=address[8],
            dest_ip='.'.join(str(part) for part in address[4:8]),
            dest_port=address[9],
        ) if address_family == 'AF_INET' else None,
    )

async def recv_num_bytes(loop, sock, num_bytes):
    incoming_buf = bytearray(num_bytes)
    incoming = memoryview(incoming_buf)
    bytes_in_total = 0

    while bytes_in_total != num_bytes:
        bytes_just_in = await loop.sock_recv_into(sock, incoming[bytes_in_total:])
        if bytes_just_in == 0:
            raise Exception('Socket closed')
        bytes_in_total += bytes_just_in

    return incoming_buf




async def main(loop):

    port = 8080

    server_sock = socket.socket(family=socket.AF_INET, type=socket.SOCK_STREAM, proto=socket.IPPROTO_TCP)
    server_sock.setblocking(False)
    server_sock.bind(('', port))
    server_sock.listen(socket.IPPROTO_TCP)

    while True:
        print('Waiting for connection')
        sock, adddress = await loop.sock_accept(server_sock)
        header = await proxy_protocol_header_recv(loop, sock)
        print(header.address.source_ip)


if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(main(loop))

