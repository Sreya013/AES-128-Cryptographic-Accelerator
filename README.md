# AES-128 Cryptographic Accelerator IP

A SystemVerilog implementation of an AES-128 encryption accelerator with an AXI4-Lite interface and a UVM-based verification environment.

This project was developed to understand both sides of the design process — implementing a cryptographic algorithm as RTL and verifying the hardware using SystemVerilog and UVM.



## Overview

AES (Advanced Encryption Standard) is a symmetric encryption algorithm widely used to protect digital data.

In this project, I implemented an AES-128 encryption accelerator in SystemVerilog.

The design takes:

 128-bit plaintext
 128-bit encryption key

and produces:

 128-bit ciphertext

The AES encryption is performed through 10 rounds using the standard AES transformations.

The design uses an iterative architecture, where the AES round datapath is reused across the encryption rounds.

An AXI4-Lite slave interface is also implemented so that the AES accelerator can be accessed through memory-mapped registers.



## AES-128 Encryption

The AES-128 encryption process consists of:

1. Initial AddRoundKey
2. Rounds 1–9
    SubBytes
    ShiftRows
    MixColumns
    AddRoundKey
3. Final Round
    SubBytes
    ShiftRows
    AddRoundKey

The final round does not contain MixColumns.

The 128-bit encryption key is expanded into 11 round keys using the AES key expansion algorithm.



## RTL Design

The AES accelerator is divided into multiple RTL blocks, with each block handling a specific part of the design.

### Main RTL Components

- AES top-level module
- SubBytes
- ShiftRows
- MixColumns
- AddRoundKey
- Key Schedule
- Control FSM
- Round Counter
- Register File
- AXI4-Lite Interface

The control FSM controls the encryption sequence and keeps track of the current AES round.

The iterative datapath allows the same AES round hardware to be reused instead of implementing separate hardware for all 10 rounds.



## AXI4-Lite Interface

The AES accelerator uses an AXI4-Lite slave interface for communication with the testbench or an external processor.

The interface handles:

- Write Address Channel
- Write Data Channel
- Write Response Channel
- Read Address Channel
- Read Data Channel
- VALID/READY handshaking

The AES key and plaintext are written into memory-mapped registers through AXI4-Lite.

The encryption is started through a control register.

The status register is then read to determine when encryption is complete.

Finally, the ciphertext is read from the output registers.



## NIST FIPS 197 Verification

The RTL was tested using the standard AES-128 known-answer test vector from NIST FIPS 197.

### Plaintext
3243F6A8885A308D313198A2E0370734
## Key
2B7E151628AED2A6ABF7158809CF4F3C
## Expected Ciphertext
3925841D02DC09FBDC118597196A0B32
## DUT Ciphertext
3925841D02DC09FBDC118597196A0B32

## Result
The RTL output matches the NIST expected ciphertext.

## UVM Verification

After completing the RTL design, I created a UVM verification environment to verify the AES accelerator.

The verification environment follows the standard UVM structure:

                  Sequence
                     |
                 Sequencer
                     |
                   Driver
                     |
                    DUT
              AES-128 Accelerator
                     |
                  Monitor
                     |
                 Scoreboard
                     |
              Reference Model
UVM Components
## Transaction

File: aes_transaction.sv

Represents one AES operation.

It contains:
Plaintext
Key
Ciphertext

Plaintext and key can be randomized for constrained-random testing.

## Sequence

File: aes_sequence.sv

The sequences define what stimulus should be generated.
Three sequences were created:
NIST sequence
Random sequence
Corner-case sequence
The NIST sequence sends the known NIST test vector.
The random sequence generates different plaintext and key combinations.
The corner-case sequence checks specific input patterns such as all-zero and all-one values.

## Sequencer

File: aes_sequencer.sv

The sequencer controls the flow of transactions from the sequence to the driver.
It acts as the connection point between the sequence and driver.

## Driver

File: aes_driver.sv

The driver receives an AES transaction from the sequencer and converts it into actual AXI4-Lite signal activity.
For one AES operation, the driver:
Writes the key registers
Writes the plaintext registers
Writes the control register
Waits for encryption to complete
Reads the ciphertext registers
The driver communicates with the DUT through a virtual interface.

 ## Monitor

File: aes_monitor.sv

The monitor observes the AXI4-Lite interface without driving any signals.
It reconstructs an AES transaction by observing:
Key writes
Plaintext writes
Status reads
Ciphertext reads
The completed transaction is then sent to the scoreboard.

## Scoreboard

File: aes_scoreboard.sv

The scoreboard is responsible for checking the DUT result.
It receives the transaction captured by the monitor.
The plaintext and key are passed to an independent AES reference model.
The reference model calculates the expected ciphertext.
The scoreboard then compares:

DUT Ciphertext
      vs
Expected Ciphertext

If they match, the transaction passes.
If they do not match, the scoreboard reports a failure.

## Reference Model

File: aes_ref_model.sv

An independent AES-128 reference model was written in SystemVerilog.
It implements the AES algorithm separately from the RTL.
The reference model contains:
AES S-Box
Rcon
SubBytes
ShiftRows
MixColumns
AddRoundKey
Key Expansion
AES Encryption

The purpose of having a separate reference model is to calculate the expected result independently.
This allows the scoreboard to automatically check the DUT for every transaction.

## Functional Coverage
Functional coverage was added to track which input scenarios were exercised during verification.
The coverage checks include:

All-zero plaintext
All-one plaintext
Different plaintext ranges
All-one key
Different key ranges
Plaintext MSB ranges
Key MSB ranges
Cross coverage between plaintext and key ranges

This helps determine whether the verification environment has exercised a useful range of scenarios.

## Assertions

SystemVerilog Assertions were also created to check protocol and timing behaviour.

The assertions check conditions such as:
AXI outputs remain inactive during reset
awready does not become active during reset
rvalid does not become active during reset
enc_done does not become active during reset
Write address handshake occurs within the expected time
Read address handshake occurs within the expected time
Write response appears after a write transaction

These checks help detect protocol and timing problems independently of the scoreboard.
Verification Tests
1. NIST Test
Runs the official AES-128 NIST known-answer test.
Purpose
Check basic AES functionality
Verify the implementation against a trusted test vector
2. Random Test
Runs randomized plaintext and key values.
The current test configuration runs:
20 random transactions
The key constraint prevents the key from being all zeros.
3. Full Test
The full test combines:
NIST test
Random transactions
Corner-case tests
This provides broader functional testing.

## Verification Results

The final UVM simulation produced:

AES-128 Verification Summary

Total      : 26
Passed     : 26
Failed     : 0

UVM_ERROR  : 0
UVM_FATAL  : 0
Final Result
ALL TESTS PASSED
AES-128 VERIFIED
Waveform Analysis

The simulation waveforms were analysed to understand both the AXI4-Lite communication and AES operation.

## Important signals observed during debugging included:

AXI Write
awaddr
awvalid
awready

wdata
wvalid
wready

bvalid
bready
AXI Read
araddr
arvalid
arready

rdata
rvalid
rready
AES
enc_done
round counter
state
round key
ciphertext

The waveform analysis helped verify that the address, data and response handshakes were happening correctly and that the AES operation progressed through the expected rounds.


## Tools Used and Tool	Purpose
AMD Xilinx Vivado 2025.2	RTL design and simulation
Cadence Xcelium 25.03	UVM simulation
EDA Playground	UVM development and waveform analysis
SystemVerilog	RTL and verification
UVM 1.2	Verification methodology

## What I Learned

This project gave me hands-on experience with both RTL design and functional verification.
Some of the major concepts I worked with are:

AES-128 encryption
SystemVerilog RTL design
GF(2^8) arithmetic
AES key expansion
Iterative datapath architecture
FSM design
Round-based control
AXI4-Lite protocol
VALID/READY handshaking
SystemVerilog interfaces
Virtual interfaces
UVM transactions
UVM sequences
Sequencers
Drivers
Monitors
Agents
Environments
Scoreboards
Reference models
Constrained-random verification
Functional coverage
SystemVerilog Assertions
Waveform debugging

One of the most useful parts of the project was understanding how the RTL and verification environment work together.

The sequence generates the stimulus, the driver converts it into AXI transactions, the DUT performs the encryption, the monitor observes the result, and the scoreboard checks it against the independent reference model.

## Project Status

Completed

AES-128 RTL implemented
AXI4-Lite interface implemented
NIST FIPS 197 test vector verified
UVM verification environment implemented
Randomized testing completed
Corner-case testing completed
Scoreboard checking implemented
Functional coverage added
Assertions added
Waveforms analysed
26/26 transactions passed
0 failures
0 UVM errors
0 UVM fatal errors

## Author
Sreya
ECE Graduate | VLSI | RTL Design | Design Verification

## Interested in opportunities in:
RTL Design
Design Verification
ASIC/SoC
VLSI
