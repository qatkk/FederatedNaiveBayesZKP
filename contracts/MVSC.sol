// This file is MIT Licensed.
//
// Copyright 2017 Christian Reitwiessner
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
pragma solidity ^0.8.0;
library Pairing {
    struct G1Point {
        uint X;
        uint Y;
    }
    // Encoding of field elements is: X[0] * z + X[1]
    struct G2Point {
        uint[2] X;
        uint[2] Y;
    }
    /// @return the generator of G1
    function P1() pure internal returns (G1Point memory) {
        return G1Point(1, 2);
    }
    /// @return the generator of G2
    function P2() pure internal returns (G2Point memory) {
        return G2Point(
            [10857046999023057135944570762232829481370756359578518086990519993285655852781,
             11559732032986387107991004021392285783925812861821192530917403151452391805634],
            [8495653923123431417604973247489272438418190587263600148770280649306958101930,
             4082367875863433681332203403145435568316851327593401208105741076214120093531]
        );
    }
    /// @return the negation of p, i.e. p.addition(p.negate()) should be zero.
    function negate(G1Point memory p) pure internal returns (G1Point memory) {
        // The prime q in the base field F_q for G1
        uint q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;
        if (p.X == 0 && p.Y == 0)
            return G1Point(0, 0);
        return G1Point(p.X, q - (p.Y % q));
    }
    /// @return r the sum of two points of G1
    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
    }


    /// @return r the product of a point on G1 and a scalar, i.e.
    /// p == p.scalar_mul(1) and p.addition(p) == p.scalar_mul(2) for all points p.
    function scalar_mul(G1Point memory p, uint s) internal view returns (G1Point memory r) {
        uint[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require (success);
    }
    /// @return the result of computing the pairing check
    /// e(p1[0], p2[0]) *  .... * e(p1[n], p2[n]) == 1
    /// For example pairing([P1(), P1().negate()], [P2(), P2()]) should
    /// return true.
    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        require(p1.length == p2.length);
        uint elements = p1.length;
        uint inputSize = elements * 6;
        uint[] memory input = new uint[](inputSize);
        for (uint i = 0; i < elements; i++)
        {
            input[i * 6 + 0] = p1[i].X;
            input[i * 6 + 1] = p1[i].Y;
            input[i * 6 + 2] = p2[i].X[1];
            input[i * 6 + 3] = p2[i].X[0];
            input[i * 6 + 4] = p2[i].Y[1];
            input[i * 6 + 5] = p2[i].Y[0];
        }
        uint[1] memory out;
        bool success;
        assembly {
            success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success);
        return out[0] != 0;
    }
    /// Convenience method for a pairing check for two pairs.
    function pairingProd2(G1Point memory a1, G2Point memory a2, G1Point memory b1, G2Point memory b2) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](2);
        G2Point[] memory p2 = new G2Point[](2);
        p1[0] = a1;
        p1[1] = b1;
        p2[0] = a2;
        p2[1] = b2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for three pairs.
    function pairingProd3(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](3);
        G2Point[] memory p2 = new G2Point[](3);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        return pairing(p1, p2);
    }
    /// Convenience method for a pairing check for four pairs.
    function pairingProd4(
            G1Point memory a1, G2Point memory a2,
            G1Point memory b1, G2Point memory b2,
            G1Point memory c1, G2Point memory c2,
            G1Point memory d1, G2Point memory d2
    ) internal view returns (bool) {
        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        p1[0] = a1;
        p1[1] = b1;
        p1[2] = c1;
        p1[3] = d1;
        p2[0] = a2;
        p2[1] = b2;
        p2[2] = c2;
        p2[3] = d2;
        return pairing(p1, p2);
    }
}

contract Verifier {
    using Pairing for *;
    struct VerifyingKey {
        Pairing.G1Point alpha;
        Pairing.G2Point beta;
        Pairing.G2Point gamma;
        Pairing.G2Point delta;
        Pairing.G1Point[] gamma_abc;
    }
    struct Proof {
        Pairing.G1Point a;
        Pairing.G2Point b;
        Pairing.G1Point c;
    }
    function verifyingKey() pure internal returns (VerifyingKey memory vk) {
        vk.alpha = Pairing.G1Point(uint256(0x1f60e4d396e5ee011d285003f5ddd1eb03e2afac261ec6b6c30fd9102b70b891), uint256(0x12ac97b9391b05a05187fffea8fd0e1f1cbdefcb7dec871d8726f9dc3806f3e5));
        vk.beta = Pairing.G2Point([uint256(0x261c64db442455e66767a9247b3bfb8a113dc987450c7959c85bedfdfdc94475), uint256(0x1160752268971ff522205033678d40f80d06d4efee09a26411014af00b65ae74)], [uint256(0x2ca5b02e0603ef99596e3da2237712c48621f5379a3fa23f224ba650573fe4a9), uint256(0x2b3d66a323b1bb2a797c2a8ea55ecfa6134aa7ea477d065e4bf5b21f7ec393b8)]);
        vk.gamma = Pairing.G2Point([uint256(0x2c56a48c58c5ef3984bf098aa14eba439cd5638dbc3f87e9b1a211b5e6970ce8), uint256(0x020ee3e3e1f6e46ec5ddc1713adf98f04ee8b5c9bfdec456745a5153d9386530)], [uint256(0x08cf3956eecd50c0d27f3b7623598eb67af4928217df5912778f6a9df9080fa3), uint256(0x27542e9da23f9fa54d036cf0479a547331a94e9c194cf3f90fffeffc05a21c77)]);
        vk.delta = Pairing.G2Point([uint256(0x266f83848864d942c09c789efc0be4e5560a6fe9a3f42d0168f929df7e5c45b4), uint256(0x15888ca3dc70cc00f11131d9e4895bf57ea0d3764a25b40d1fb39f1316968037)], [uint256(0x27ecac7f11bbd8083f67b55838d3588f6fb2aee22a54354929039eab7b0da77e), uint256(0x0a0abf1dfe34450bf2a46598dfb8c51893f175885e24809c2e15b1df500c2385)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0c945c7768f02d6b4333c1c73fa71c8ae90011495cd026f3e274738b21104b94), uint256(0x07d6c39c967479c53616232b432008a168ddca6099b9711aae11f8cfac427676));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x27de4fe321da192d7e06937b018d34250ef1243ace409a5ba4580128cc4a7f18), uint256(0x1febce4bcec28c025e1e5a8486b6d46e4291b6f7265a19027166150945c5f9f3));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x034726583e38ff7b5437ea7f447d6e2f4fe024e82f8cbe64ea7879c0bd36f08e), uint256(0x200b9d069567575260ba72c1901f983cfffb48050771c3a6be96f23994c2b09f));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1c4bf7306e15333750e116f5ff4609cd9df0af457466604d59275cb0e5e7dca3), uint256(0x2357fff39f9bbd5dde61bc9045b83576ccb45e781dd8f3d72727b6c3da13dbee));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x23a070e0d42cf73aa3ede84abf140b8cbeda009a37600e3d336a16bf3500c139), uint256(0x1b00651586002a8748d33d926849d2cce761f2566686b7dde73ff31127050568));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x08c7a86b3059391ead98cbe772503e35a707fe87b42e73326bcccd301552390b), uint256(0x1cf86e5194aff36a00f064ccb5f985491f59c651b392cf0ded385b1304ca45fb));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0b02d2845b48f20255ec07acab55ceccadd21e67430b2bf403a6a4c8916ef4ff), uint256(0x252910d4a60332a0790ce28b25b285317054118b379f615e380ae91f24d78ee6));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1ff42de3f2221a3047cc5a9796dbc90c4df09229089611cf167b98d98baf04c8), uint256(0x08805600e739ddf15e14f038050743b0fe2e04745c0e4f1e60d150af772f9958));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x12003469c55accb90e864d17fd67db7abd69ec7a8e4efaa71098855bfeb07aaf), uint256(0x179d12c8c12601e7af284662179b2cd0a6451237208f42ad45ef278c70283a16));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x077929dc53d9331fb5ef05b200bf92a99353c353c2309632f0dedc3bbfe241ae), uint256(0x1ffb75f87b52568f02733b084a51debee98f2340fbd94550b1b786c9a648fff4));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1acc87ef371ee6896891c25dcaa49dcb10ee970803728d68a6b5289df974abdf), uint256(0x29fd127f13485eb64678e25a9f7bf7d86ebb72f87a59425bf4894777e384b233));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1aced2826b94bc550f8739b8d79f7f8320e5d0656fdf71dbe92f0ac0cacc787d), uint256(0x04fca71a3a2abd16f102606b42008a7968a65a405bef514c7db9ce69db8262a3));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x177ed89662c5f14eacf68b12fe3ec9fdf4031fd0f2c05f68bcc315abf0d78947), uint256(0x039b185c1a8ea0e13c6e0825f8c3407ef40c376881870084f1f02a0e42ae1a8c));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x22c528481eea3282dbbc6f80bf2a3bd94f1a166b1bbb0e1facf0c3c3229080f0), uint256(0x24daf8fe026013dd847534364cc45e998203f1206be0398f359e1f92ad306849));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1b71a3ac3ae13c456b47ec87632e4909b56fdf4539646d912998f1e48946e9dc), uint256(0x09bad17e7669c4d929d602c0aa4d8e93d01ed7879cb147869252ab3acb25bc54));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1c2888688a23eb05186457e2c7f00c062af474e4610dbcd7ae569a058bfbb6e9), uint256(0x2ff384a8ba22275a4f621f7c6f2b732199c6aedb6d8ca49b29939ec5c15e61a9));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x28858bce322f38951c2c010daeffaa9d33c92fe1d0df91e9bef3faa55ba7ef10), uint256(0x16cc4d0cd7bd5cfe3731be7ab067209de64687a21be1c5b298c81517c3b50927));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2eae0a87d3c6a3d7a0e6cc3eb4068d3f4586e76960aa6624255547d4dc1f6f28), uint256(0x107985e3f18c323bad5ed254a6908a9ca1e978df36fa8aa2e4b4d88391cd1f84));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2dee97f7240af698f9f4f9d775dba6a9f8119fb5948b3066226b9143e3498228), uint256(0x1f1e7fd2cfb12228d93187f433408cc41ec294876e0f2aa6e3138872794b2c39));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2a617cd4f478c3c9af34bb90bdcb3a7e2ee7a1a4c04c3a37638bd21fdad6ede0), uint256(0x12bb83a59b55840621149c9ca45c4de7f34e1b00bbaa2f9424bbca76e7d65fe5));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1a540fd4600d7e8aa1bbc868aba40c9ee623365bf77e31c7246ee6671450cdb8), uint256(0x10fad00aed88a2bfbdf7e3bf28f902a3d9c10a20749386ad2629e34729b16d07));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0bda8e43e6bc485bb96b55a3aca8d2cbda9823ac29051e6d6b7686ef13d227e9), uint256(0x0ed409841e538d91d5fae0aff37f233ae291d844e4e83c071d48623e2ecfe1a0));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2c6c452acb70c51937602fcca71b225c24bd8c837204a09292434db03e48d7f8), uint256(0x301b170d73a4562e2e1590f5e2eb8205c57f612481ebbc2303e8fa7e50a259f3));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0bfdabd13fd862e59a2523a6dcaf2b2e62c64b3f9740c54f7f545e57aa605a2c), uint256(0x0b97964b1a48f201139b293707f970f53cc559fa281d3cd9b90cf544a7614216));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0162af478c3c839a6e4e7c0777fea8bbb30bad9a409f0d01a1b6aab87be3172c), uint256(0x1675a4d62ab2bb022fe81ad923501979a65cfc9388f97ad6131546938c732da2));
    }
    function verify(uint[] memory input, Proof memory proof) internal view returns (uint) {
        uint256 snark_scalar_field = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
        VerifyingKey memory vk = verifyingKey();
        require(input.length + 1 == vk.gamma_abc.length);
        // Compute the linear combination vk_x
        Pairing.G1Point memory vk_x = Pairing.G1Point(0, 0);
        for (uint i = 0; i < input.length; i++) {
            require(input[i] < snark_scalar_field);
            vk_x = Pairing.addition(vk_x, Pairing.scalar_mul(vk.gamma_abc[i + 1], input[i]));
        }
        vk_x = Pairing.addition(vk_x, vk.gamma_abc[0]);
        if(!Pairing.pairingProd4(
             proof.a, proof.b,
             Pairing.negate(vk_x), vk.gamma,
             Pairing.negate(proof.c), vk.delta,
             Pairing.negate(vk.alpha), vk.beta)) return 1;
        return 0;
    }
    function verifyTx(
            Proof memory proof, uint[24] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](24);
        
        for(uint i = 0; i < input.length; i++){
            inputValues[i] = input[i];
        }
        if (verify(inputValues, proof) == 0) {
            return true;
        } else {
            return false;
        }
    }
}
