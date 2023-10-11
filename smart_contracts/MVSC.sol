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
        vk.alpha = Pairing.G1Point(uint256(0x2c80a5fbdff827265dce4afbbc7febb5dddcbbbff23816faa3b6e7d8311be478), uint256(0x056848af336f754d0a07c396f652cb4704ccec3ede755dc8136c51295d82d08a));
        vk.beta = Pairing.G2Point([uint256(0x2b06ceaf82284ea4408b490502f4730f4aa2299296be8f7122920bf10d1603f3), uint256(0x027bd4f476170159c93b5e84c46cbae109dc4d94c494cda101f1795114769e9b)], [uint256(0x2a0ace3c6e62a6fd5c3e9e3cdfe4a0333034bc03ed0e76eb88ef0c7d1343d4d2), uint256(0x2e2f892b61c46ec7454b68b2462b95bf639f81d846e118a1b2d1f9a6bec8a3d6)]);
        vk.gamma = Pairing.G2Point([uint256(0x0e213e85dd8cf8c8a6567b5025d6239dcd96b1a87ad62f456d6dafe6445039ad), uint256(0x0422ce1d2c1994faafccd9b9d50fa18f5d433d923c0a60967c10df00838d8147)], [uint256(0x1076fd621e33eb71f602c1d0e1a7414df6ecd791c3196659ce4726e13f626295), uint256(0x14fc27ade8f663df4e0618da927c545e9476e230f064cac8fbdceac1870e5f85)]);
        vk.delta = Pairing.G2Point([uint256(0x05494a5e6a67d6b0b3f522d303cc31fd6061619ff6f02886e486ecb3a721378f), uint256(0x14e8e28ab44d521d4033e7d71cdd3e0e911f77b0bde298dff0fdd834ed61cb47)], [uint256(0x1bd2d9764fbe5f6588aaeb32fda64f1332d2b4af4e8a9645e07f81d28e0ef196), uint256(0x254e4fd22b684a5298e85cb54c85fb5ba264fb334f6063b8ad9c1c4cd4535280)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2292f8f696583e22ccf7a4ec23f232e6a8bad1d5c13530ccb6e982cb74b17087), uint256(0x2fcffd34d053469f9b03a1866cc47848596e414d062b1d5f82ebbbb832152713));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2275a41659809443ed87658cbe5388f608739c0e7601ee4de15e6c1eb116ab43), uint256(0x1bf5d2e1810a5014b6d7209a196e8d9cceb699b294cc0363ec37737ddba93c31));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2301379f27f2e3309e77bc007c7637223efff9f142af13b538529666b72a5f23), uint256(0x2784e6f9597ad6afe59e242b81ada07aa4187ca2e3e2fc27c344dbd947769e84));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x17deb0201d414d8561b09e8559dd3878b7998d49915a4946bbc2c22c779752be), uint256(0x0ae6165d6b1e98c4a2e6da435c652de5c3a16e2553c0056d3c9c9e335daf8be4));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2662d64a67c60a70909c40f98a82e00c06a8e212866b1d0a6a699f49ac29b8bb), uint256(0x1395171cadd2ff5fb64d69b02705cee8d85f5d0aa68d925b35ca3cc90078573f));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x26ad2b2027c4e7de662c4aa8447eaeafd24b626077c50eb5bdaea2db3392d83c), uint256(0x27e0f29ed971ee0e01a9a37abfed4c6f7ed5376699d04bf32f19f217ca15b3d3));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x120c36ef1485586553dbf739835c48777d5f7a3753df0000b64640aa0ae145b1), uint256(0x10328a6f9732a4f88df8d2e7751d9d71e4f7a7bf1792654ce67619339dc34019));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2b97674ae0a86162e3ec2d137c094138f307a488f1b971091be0e9fe0fd2ea24), uint256(0x27804a60be4ac6fec74151cc7ee1dcda38197cfe35bcfe2b1049c94ab8a5b738));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2df33141ced1bbf06cee18c347722647f81f6ac17227178a40ab138675bcfdcd), uint256(0x1534db073894b5e186eca82b532e23d3584f22150e60f48300a8442090216e2c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x19105069b0760923e6e3af90d99c755b5b4f7cb1676d0d8757b1f5fd8af96221), uint256(0x2674de412a3ca9b5060101a444023229b34d6e78bbca14f44034837dba1a3da2));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1f2c4fc1f695e52cecf0e468fb159468651281476055a30e1de4e4529aeea71e), uint256(0x11fb712e5f4cebc4e9fe3188d1e7beba222bb3066379a13b48c2d983f7ee7dc0));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2b360b427763194e8542a8667c0891f0866a165507b1753e575ccfd28824a842), uint256(0x12b499cf1f9f502b1910ad1afcb18965077b45f8750764ca05a65b2a1744d980));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2ccdda6fca094daa0afc4848714b0430114edac12d38b10f8c6121367044d196), uint256(0x0559d0fcd4ec3199298603adb02c28577a1b978d0e04d435f756ce4d488eb751));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x05896f851d8013da1afea2a4bc42fff3e8e63119f835f6cc47da0a68299f8153), uint256(0x1f9c1dab6f026781d3f6f38f7e88c4616c4c4312ed302af98e6f73f9d2ca44b1));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0e014f607d7e14020040bfeba6e997cc7cccfdab40c40438470a678779dc5e0f), uint256(0x26a3e13459abf56475bcbd9b92bb3eaf71652ef7f098a01aa114632204561977));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2fd8e9623705dce9fa4a8678e4da92496002d3d35e2701b53bf17ba703cde010), uint256(0x0ef9ecbd2a0f41df151fc170e9bca4e9c7211825b237e88cf73e72489deeeac9));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x25779becfc52242d2646b9cb0e69489461b281c53deb7f1b42ffc1b2488aef8f), uint256(0x0e40cd4865f726c36e2402d448f3e56b4a9975dca1453dc5ae26f565e1c8e917));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x00b9a4c9bdab1d14ca71c4d93745c77387f9f726255f8769155bc26331df8ab0), uint256(0x103abd52208151de072af4043e5b2e857a19accf0ffaf333a71023f721d82255));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1379a32889c99f2cf1689043cd1942894d1bd367d8da2473bcc10f2f28a033cc), uint256(0x28c33d80507864c34744d7683ca28a08ad059a7cae515a84e89e7ca082ec80cc));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x1fe4b58a739d2ca4c3477b57cfcb4fff0975a133c21a39816f56f22a005a25c5), uint256(0x010ca1007e75126947b2585a5823820882d6930063746fb64674dd751cb2ece1));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0bceec38429a49e615abd14a319e521ccdca0a69a5c178f0e85a7b03685e0d01), uint256(0x260b8310e0d7f8b0a4eb78b656104e1fbff70454487094f0c59e112681999b83));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x173077e02a14987b4967f4b20617884145caa44f8d88b993c062842216bb9d20), uint256(0x03473c8c0b1548e8c63d25ba55279077f6a98b3cc85b27837e8f3066f00b9990));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2ae647fba1631bd180142d4ca57205ea1ebfb469835cf1f56d5b12d0c9f27c93), uint256(0x1493589a60ed5c680f4b29c7dc76390aa382f73d1943cdc11df9e85e93176152));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x02e4c28ebda9930f8eea433d12a4fe3f40218710e592dca8617c7896f574a860), uint256(0x2ee3f8edf3f7b61323af57a531a1c36bb1777c2f00440834744b6752e151fa15));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1e213aaccd8eb509368956a6458f5c08c22eaa616cd65bf3cbf0ee31c66791c4), uint256(0x1874bbe3b8f5a9d65bcb3e95cf32ffb8f01ba1beb0e489327f3e8d1faa5aabe1));
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
