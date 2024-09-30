// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.6.11;

library CryptoPairing {
    struct PointG1 {
        uint X;
        uint Y;
    }
    
    struct PointG2 {
        uint[2] X;
        uint[2] Y;
    }

    // Returns generator of G1
    function generatorG1() internal pure returns (PointG1 memory) {
        return PointG1(1, 2);
    }

    // Returns generator of G2
    function generatorG2() internal pure returns (PointG2 memory) {
        return PointG2(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
    }

    // Returns the negation of a G1 point
    function negateG1(PointG1 memory p) internal pure returns (PointG1 memory) {
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0) {
            return PointG1(0, 0);
        }
        return PointG1(p.X, q - (p.Y % q));
    }

    // Adds two G1 points
    function addG1(PointG1 memory p1, PointG1 memory p2) internal view returns (PointG1 memory r) {
        uint[4] memory input = [p1.X, p1.Y, p2.X, p2.Y];
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            switch success case 0 { invalid() }
        }
        require(success, "Addition failed");
    }

    // Scalar multiplication of a G1 point
    function mulG1(PointG1 memory p, uint s) internal view returns (PointG1 memory r) {
        uint[3] memory input = [p.X, p.Y, s];
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            switch success case 0 { invalid() }
        }
        require(success, "Multiplication failed");
    }

    // Performs pairing operation
    function pairingCheck(PointG1[] memory p1, PointG2[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length, "Length mismatch");
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++) {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[0];
            input[i * 6 + 3] = p2[i].X[1];
            input[i * 6 + 4] = p2[i].Y[0];
            input[i * 6 + 5] = p2[i].Y[1];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            switch success case 0 { invalid() }
        }
        require(success, "Pairing failed");
        return out[0] != 0;
    }

    // Convenience functions for pairing checks
    function pairingProd2(PointG1 memory a1, PointG2 memory a2, PointG1 memory b1, PointG2 memory b2) internal view returns (bool) {
        PointG1;
        PointG2;
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairingCheck(p1, p2);
    }

    function pairingProd3(
        PointG1 memory a1, PointG2 memory a2,
        PointG1 memory b1, PointG2 memory b2,
        PointG1 memory c1, PointG2 memory c2
    ) internal view returns (bool) {
        PointG1;
        PointG2;
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
