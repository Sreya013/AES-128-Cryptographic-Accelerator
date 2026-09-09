# AES-128 Cryptographic Accelerator IP

A SystemVerilog implementation of an AES-128 encryption accelerator with an AXI4-Lite interface

This project was built to understand how a cryptographic algorithm can be implemented as RTL and then verified using a proper SystemVerilog



## About the Project

AES (Advanced Encryption Standard) is a symmetric encryption algorithm widely used for securing data.

In this project, I implemented the AES-128 encryption algorithm in hardware. The design accepts a 128-bit plaintext and a 128-bit encryption key and generates a 128-bit ciphertext.

The design uses an iterative architecture, where the AES round datapath is reused for the encryption rounds instead of having separate hardware for every round.

The RTL was developed and tested in **AMD Vivado**, and the verification environment was developed using **SystemVerilog**



## AES-128 Encryption Flow

AES-128 uses 10 encryption rounds.

The main operations implemented in the design are:

1. AddRoundKey
2. SubBytes
3. ShiftRows
4. MixColumns
5. AddRoundKey

The final round does not contain MixColumns.

The encryption key is also expanded into round keys using the AES key expansion algorithm.

---

## RTL Design

The AES accelerator is divided into smaller modules so that each part of the algorithm can be developed and understood separately.

### Main RTL blocks

- `aes_top.sv` - Top-level AES accelerator
- `aes_if.sv` - Interface definitions
- `aes_fsm.sv` - Control FSM
- `aes_subbytes.sv` - SubBytes transformation
- `aes_shiftrows.sv` - ShiftRows transformation
- `aes_mixcolumns.sv` - MixColumns transformation
- `aes_addroundkey.sv` - AddRoundKey operation
- `aes_keyschedule.sv` - AES-128 key expansion
- `aes_regfile.sv` - Register file
- `aes_axilite.sv` - AXI4-Lite interface

The AES datapath is controlled using an FSM and round counter.



## AXI4-Lite Interface

The accelerator uses an AXI4-Lite slave interface for communication.

The interface handles:

- Write address
- Write data
- Read address
- Read data
- VALID/READY handshaking
- Response signals

I also analysed the AXI transactions using simulation waveforms to make sure that address and data transfers occur correctly.




**Plaintext**
3243F6A8885A308D313198A2E0370734

**Key**
2B7E151628AED2A6ABF7158809CF4F3C

**Expected Ciphertext**
3925841D02DC09FBDC118597196A0B32

The RTL produced the expected ciphertext.

## Tools & Technologies

.SystemVerilog
.AMD Vivado
.RTL Design
.AXI4-Lite
.AES-128
.Digital Design & Verification

## Key Features

.AES-128 encryption
.128-bit plaintext input
.128-bit encryption key
.Iterative AES round architecture
.FSM-based control
.AES-128 key expansion
.AXI4-Lite slave interface
.SystemVerilog-based verification
.Simulation waveform analysis

## How to Run

.Clone or download this repository.
.Open the AES project in AMD Vivado.
.Add the RTL source files and simulation testbench.
.Set the appropriate top module and simulation top.
.Run behavioral simulation.
.Apply the AES-128 test vector given above.
.Observe the generated ciphertext and simulation waveforms.

## verification
The expected ciphertext for the test vector is:
3925841D02DC09FBDC118597196A0B32

## Project Status
The AES-128 encryption accelerator has been implemented and verified through SystemVerilog simulation using the standard AES-128 test vector.

## Simulation results and encryption waveform 
final ct waveform.png
handshakes waveforms.png
internal datapath waveform.png


**Author**
Sreya.P
Electronics and Communication Engineering Student

Interested in RTL Design, VLSI, FPGA .
