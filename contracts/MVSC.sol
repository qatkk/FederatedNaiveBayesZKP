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
        vk.alpha = Pairing.G1Point(uint256(0x087f727b32b966894b317f9249e9d2aaf9fbc8ce65944764d6467c569b0fe569), uint256(0x29d50f5374264af1428e5ebc3ac5611bea0bb3cd418daa8cbf5fdb4333904256));
        vk.beta = Pairing.G2Point([uint256(0x22af85ed0a9ebd870c428f34c14aa71532279b2096d767cb466036c50f32bf90), uint256(0x00b2705ab4cd6ee9286b1211413e123d9a16677e4aaacbb9f24d2c730815ddd5)], [uint256(0x1917c93f3af3b62558ab8d5cbcbc4543f728a4bb42cefdb830b9510158553ccb), uint256(0x21702bf96b405249d04d8dc94f411dcd7e1e26b4681c9b1ce69a331a28bd6506)]);
        vk.gamma = Pairing.G2Point([uint256(0x00ece4c9a2807d845b99b6c6432dab7eb7a7f5d9d3c40fcd71734ddcbb8a2575), uint256(0x04bc36de69493aeb79cc7981d5383bedba065e13d072fc5365d33328bd5f94d8)], [uint256(0x2eb8a6954d6e7725f66e77e463df3b813255b444f2b6bb8c99ba39dd682e0f96), uint256(0x2ae67f4b676aff858c0f35c71bce748f476612728ef89b8e40b2b5561c9f1c69)]);
        vk.delta = Pairing.G2Point([uint256(0x15ea01300f36e10746d762267ad6004c3ad0ca748b8668875e19a6905d4ff746), uint256(0x2f7694370589b15c174b5dff35798ab26ed25d822bd6268bc2b2cc1c1188c128)], [uint256(0x13026aa66841b738431a1215118418ef995cd0b3a573cc9230e0efde0f64ff33), uint256(0x0d504fe7486c87ae4cc344f4292dbcbca1fb1eeb854f242305176ddde68d2438)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x225cbbd27caa64b099114e09ed3e531ae96b13fec8d9b3ce7eaa36df0eaf87c6), uint256(0x0c028fcd465c5fda0d7a77bf871cda5799fa7bf3c4418d4ec8bbd21eb09b4a8f));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2888d3c58b146ecc9837f421244a07a85b31adc17cc6a32e086f0eb59aef8d76), uint256(0x27d11c078ada7a70217e510a43d03e5f421cea249dec03b6443c679490ebd734));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1370b854066a5e676daf97ed4bd9d4bcdedc68c6fb9681c1cdba69f6e57d1155), uint256(0x243b13ea91019bb57d21c29fd1b506e4cbbf462acbe0eaae6c068d6513e44fb5));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0bc3eb4eb8d05413735f150d18913d0e0df8adcd6fc026c27efdb1e086cbb6c9), uint256(0x23ba85508d184777077d864702c8d937645e9f81a0b664dea287adb2d500b63b));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2ce303511f43dabda599e6fb292b0d4d0afcad6190899f0e658e227021423ed3), uint256(0x1b58fa5a6c2edde77e89952b6f89f1d9e621ab8a8841493cab38ef36b68171ef));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x149e78f2a00aa0ef6a355bc12165f343e4ebe5513be5ab68bd21959d435b987d), uint256(0x20c48c86c4072f0f3b9431f42c2915e7df051857402e4362e1304d0c99972fc4));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x14074cc71d19ecbec123ebbd351ef8ce404b7ba3009d6aedfa5898a31be32b5f), uint256(0x2631ed38a1a4ca784e585b235ec10a2051a152e100678a4d6d1f4f58df73d1f7));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x063c5458984c49bb6fb3830c5f4fe41446786e2bbc675e2de71bbdebba7153e2), uint256(0x1eca060087101545a67aea3cb103ac2c69b48a1ef23f64e41ed4cb4f9d3777ac));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x15de3704e1fb981818db6cc8d1363298e53c56468cde81b9da3764af63f9cec1), uint256(0x0beab39505e97d99d00c732ff7f512d320901593190604aa600648752809e93a));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0ca7a1658d4ab6f0f28d60cab9b408902446942d357717bc40c57601110a4faf), uint256(0x2dfbbcb183eafac806cf516490e4429b89f15db2201f822681435f729ce7587a));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1c274763e808bd604beeb61b5dc7721fb4d64cc5dbc035f567c0aab19a7eac06), uint256(0x01e3f5f239414e93d6f3abfae132e8b4fc2d6d5009c6126b782992efc14dd40d));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x05ca851beac5dd59b3bdca084a636d780f90627bde347e119b91d355225a49c1), uint256(0x253818127ae42f37deba3696d3a782d8d7e14a39128c3fcd0cfb3ddad61f3a95));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x3037f8f95d1f54de535746d72efe30762ba44819370a0c0b4db68e733aeca3ea), uint256(0x25f4b634e984b307e86d461460dda02406eca685f92402b602969f291f034d91));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1375c8cc1c9ab3d615977deda6eeced373a4da1f0c2761139ef00950bad74960), uint256(0x05ea30e9a07dfab102e8ccbe3e8840e1034a526ea339bdd4334d7764da900f0c));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1dc14425d3c9b72849d6779db881c0aa5a91ac62dab99ce7d10e78bc7cf8d68b), uint256(0x0b27ac9e97d7284623fae4cc2f31b348a2dfb978943cfba824d6e86fd8c084ae));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x22e7ae5b57f580a398605122007e05e223d67bb7b529eb35d135fb7a50eff3fc), uint256(0x20377004400c4d3c9550cc72a002c87f1ebb709780c0552818892055f6947805));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2dd0cff0b3f9c6bf7227adaa9f410a825f3c8435808c9fed7f0ac10c7d7472e4), uint256(0x27d97462a06b64f5de22a3a4e4df6c59f63182555f39075232148ba19edbd099));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2d9d017ef781615411015d7f0d31845ff02491cc3ac02af367bef0818f6b0a9b), uint256(0x0d61a87c4ee9cfc12b27a6cd4e258b930e89cc3b24bb031b115fc8f5701dfbab));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x043dc606306d914fef56ad694fde76af838687adbaff824325d9134f78611263), uint256(0x292634e17d6e1c37290d7788e8c0002d266ff28b0552da209c7953339ac72d70));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1b59f37de1bf9a127e25d4dcf0dc21f6d4341194aa83f6b682c3fc1a167a2c2c), uint256(0x2e5de7fef2d99f05075d96f7d5d23e3c6b69cd9bd1e5ded7fc50af175d0a4331));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x02eb28f56da1901b2baef986607ef97f57e8a722b9891a1801faab5ed54f672c), uint256(0x05603f5cb9578d7a3dd1d0c019e6ce954bc746db538d118b8e278cf8d57d66ac));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2c019eeea0108e20ed2c98b27eedc06ac78b1425cb973be2691e09ad6a96b9fb), uint256(0x230b14a064b04e477e6c6b5ae4c9bed5328f4e6e30e368b65ebebf586a4642ba));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x15cf2d8fc287f557263ffd60ca85765e44230b2144f9fc33b4f7557257e67457), uint256(0x0099ca23d13d4f5cd7da20f82db0c5da5bfef3d36851606bc294554f95ea193d));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0bce8265072502a3fa66018ef3237ee2d10f8b53a8c0bc62e1e50975ddc9c556), uint256(0x16495a414017bc17dd6db30d84487d84144a438f07df7eb292d89af80eb8c3e9));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1ca7f97971e618a27d4724fc2c9f38c07f8ed19934eed8986d1a897b40564271), uint256(0x1473cb1d6c0da85a58bbe639883b441832043c000c0d934a244fc0fc790dd898));
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
