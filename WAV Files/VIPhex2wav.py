#VIPhex2vav.py 10/31/2025
#Built with CoPilot! 
import sys
import wave
# Constants
SAMPLE_RATE = 44100
FREQ_0 = 2396  # ~211 µs
FREQ_1 = 822   # ~608 µs
AMPLITUDE = 100
DC_OFFSET = 28  # This shifts the waveform upward
CENTER = 128 + DC_OFFSET  # New center is 156

def detect_format(lines):
    return all(line.startswith(":") for line in lines if line.strip())

def parse_ascii_hex(filename):
    data = []
    with open(filename, "r") as f:
        for line in f:
            tokens = line.strip().split()
            for token in tokens:
                if len(token) == 2 and all(c in "0123456789ABCDEFabcdef" for c in token):
                    data.append(token.upper())
    return data

def parse_intel_hex_with_fill(filename):
    data = []
    current_addr = None
    with open(filename, "r") as f:
        for line in f:
            if not line.startswith(":"):
                continue
            byte_count = int(line[1:3], 16)
            address = int(line[3:7], 16)
            data_field = line[9:9 + byte_count * 2]

            if current_addr is None:
                current_addr = address
            elif address > current_addr:
                gap = address - current_addr
                data.extend(['00'] * gap)
                current_addr = address

            for i in range(0, len(data_field), 2):
                data.append(data_field[i:i+2].upper())
                current_addr += 1
    return data

def encode_bit(bit):
    freq = FREQ_1 if bit == '1' else FREQ_0
    samples_per_cycle = int(SAMPLE_RATE / freq)
    half_cycle = samples_per_cycle // 2

    # Clamp values to stay within 0–255
    low = max(0, min(255, CENTER - AMPLITUDE + DC_OFFSET))
    high = max(0, min(255, CENTER + AMPLITUDE + DC_OFFSET))

    cycle = [low] * half_cycle + [high] * half_cycle
    return bytes(cycle)

def encode_byte(byteval):
#   bits = bin(int(byteval, 16))[2:].zfill(8)
    bits = bin(int(byteval, 16))[2:].zfill(8)[::-1]
    parity = '1' if bits.count('1') % 2 == 0 else '0'  # odd parity
    framed = '1' + bits + parity  # start + data + parity
    waveform = bytearray()
    for bit in framed:
        waveform.extend(encode_bit(bit))
    return waveform

def write_wav(filename, data):
    with wave.open(filename, 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(1)
        w.setframerate(SAMPLE_RATE)

        # Leader tone: ~8 sec of 0 bits (2.4 kHz)
        for _ in range(SAMPLE_RATE * 8 // int(SAMPLE_RATE / FREQ_0)):
            w.writeframes(encode_bit('0'))

        # Data bytes
        for i, byteval in enumerate(data):
            try:
                w.writeframes(encode_byte(byteval))
            except Exception as e:
                print(f"[WARN] Skipping byte #{i}: '{byteval}' caused error: {e}")

        # Trailer tone: ~1 sec of 0 bits
        for _ in range(SAMPLE_RATE * 1 // int(SAMPLE_RATE / FREQ_0)):
            w.writeframes(encode_bit('0'))

    print(f"[INFO] WAV file written to {filename}")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python hex2wav.py input.hex")
        sys.exit(1)

    infile = sys.argv[1]
    with open(infile, "r") as f:
        lines = f.readlines()

    if detect_format(lines):
        print("[INFO] Detected Intel HEX format")
        data = parse_intel_hex_with_fill(infile)
    else:
        print("[INFO] Detected ASCII hex format")
        data = parse_ascii_hex(infile)

    print(f"[INFO] Parsed {len(data)} bytes")
    write_wav("output.wav", data)
