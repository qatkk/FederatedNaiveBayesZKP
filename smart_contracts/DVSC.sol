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
        vk.alpha = Pairing.G1Point(uint256(0x2dca409edb7c98b27aad1ddaf2d87df6540c4853c3c43d0f268ebc3257da46b0), uint256(0x201c90ec746a5d42319c90a0cc0baea82533b6eaadd97392068ec08ef92da17e));
        vk.beta = Pairing.G2Point([uint256(0x153edecd7f639709ebbbaa20486765d42671e0eacae09164bb70e70bb4b3fc91), uint256(0x1ae9fedc029b512fc1ebd808557909a7c8bec47b25ebea4bda38e5d05528a033)], [uint256(0x091abc4798362093bdb88e02cb8039b7a7f3b9cd25f0e6ad5c754ac8879f7586), uint256(0x1ca65d75041313577341d939450dd6ff10306007beaba7683c4ba7b0b4c3f91b)]);
        vk.gamma = Pairing.G2Point([uint256(0x12c64a6db2bc65caffb34e97ea5345952155748b1654009c5ef28ce1caa48fc4), uint256(0x2b8c47010fc0ccddc98ecc61e52f68c3859b7ccab9e947b2e7de4aef813827f5)], [uint256(0x1acd45b9cff4ebf0c637d8343472294f1d590e07153d38be010bdda390a2acab), uint256(0x0446e6d9fe933a20f03cf694349b12e63eb43320f71b418666c563c93764a084)]);
        vk.delta = Pairing.G2Point([uint256(0x1c7e9c75c2fb9512bd9a62a5c45b5feb4c6aa02cf37051ec0a7d469cd1e91ee8), uint256(0x2335dfc1371611bab934552683815c468da4d979d83c95872eb38f59158d7563)], [uint256(0x1d6711ba1b330eea120a7e7646a82a91d2dea58f210667cf97ca5e9780aed3a7), uint256(0x1c34f71869e3b75caeb6d30538dbd18c310f5a904f5c5f06f12ca9efb8a88d4e)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1b74ceb939bd9701365f95225e14882be8d093c1ea11297adb1f6b333a65a438), uint256(0x10668ee67125dc77cbd6e828e0ba354b6cfb8ccd79cfde3da81560aa396b756c));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x072de43843f018e903169a2d278ba082375535822046e5b982c72405588b9863), uint256(0x004d60b222de5813bed844629fa43f63faee7ee8ea74a8b0df4a5363394c7841));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x28c42d9005bc6c072b69c7103c1b4ae00d8e7c6405c7a778f4714ae44a81fac2), uint256(0x1e09ef9d485eeff6822088b42c222a28b80d19fa3a886d6083639c50e1fb4037));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x021ac1fec7231d79838f3adae169a54e0faaa341b6dc2289eb3b11c1bc630073), uint256(0x002d1475492fd956c547f591b7248842fdd0ad9f7c5c979957424c143e6c04bf));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x16334a6312810be4251afc7074b00c5ccca9b14ca7c0a467e2effbf7a3be5aca), uint256(0x211e93eb9c5c355f28fbec98596fc21cb3e933d5daaec4c4c074024cdb66f682));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1d88e956a487dfd9fabadd5bc895b792ac029f0fed5f85c0e898e5fa0847a0f2), uint256(0x0ab8aa5da19faa478001d11929b89d1b6303152059ead5228b393b851ce07f23));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x29be32a9e04bf1c84362f3d149904fbbe9473f9bd2472a61d61507f5a5e74d74), uint256(0x10f313d2c7fbc5d714b84173ba9855200b68b4e7e6914dc1ad3340335d9aa6da));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x05d61839636fe8c0425026d0363231a5eec3e55d67a4c42caef4d962ed27758d), uint256(0x05e97ef17ce0de4df1b1918377d5f7df5a9eb60dc677951fb1bbd42577839998));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x24bb696d1304ab40b0c02320e482594d5f855421267783fbebfff28200ee7308), uint256(0x2c04b69cc39a970763311a1ff0ec0748c05917620aafe1f50aa207b8cb2c8a47));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0c119a21f9ca063342cebe11d7cd01f97607e679ee0954885a2e8c0d9d19a595), uint256(0x17472f9eb54034d4b39d1baef661e1aae12b141cae82ab520470d8745e58a714));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x179ecb44eeed43253ae41e2ca8c035a0f49b45977053e34feac4f2378d36245a), uint256(0x0a653535e3f31d73a23f8cee78d8dce7a548e63a44434692b5e30e049d2e87aa));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1a0752f4523645b194a9f314a494cee63a77b16fa91408a1ac7fbb1db9003af9), uint256(0x1dc9309dba5ae4f15b6e1a7ccd9720d2572ccb4e8823ea68ede0f9e99b1724f4));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x29ae5a1c98c0cac4b8e903ef289a28961f1adf6d3ea377359c986ebbf30095f8), uint256(0x1d48ca59f401909286aa1b0247ce45d89f4579d82fc94cf29eff90323dfbb973));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x0dda2ecd3a406df6081a3f612b0445e5d82cd753951170751112ecc7f1ef0c29), uint256(0x0bda56f5adc18cb5886f7a7fdfd9ea94aff879a8077f07e83e49f33046a8ea0a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x09bd33d7685d5f5d83d3cfec5b2a07f4c63106b4f8421bec7c898d784e8ee6d1), uint256(0x2fd6596beade6cc09501ea81f372e4e08ac155fd65277c29058d7dfcc5e4cf7d));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2ea2807fa482c77a95eaa69d4a066064e90d407bb7fc0a4999e12a89e043bb34), uint256(0x0a482f513ab8ac4ee7ddff966dcb8272300bb93a84ff6fd80b4d9de3d1ea42b3));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x291318dfc48f8beafddc41856021f9911e7a3aee6bb02a5db7be582efd4978ab), uint256(0x1d1b358138138cbfff2bd684e71ec37735a1ac5e8e95f70d099daacf08886fee));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2ff3213ebb37878ceed8c82e85416d848e4a202ee25a9c14f3eb85c1cf99fa47), uint256(0x15ead22e2cfb034dc6c505e8f1be620c2d6074a3d9f97253d89e34c16c48cff2));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2c7461467ff45516110cf6e3a07289893b43f379a1197ba18e059999ccf9229d), uint256(0x1dd34bd8cf17a0385591cf021709f6f6b3c2c7df35b02eba7fb7a3d28e8e09db));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x15322e10d024566eaa5cc1e82e408d34778e8683fdb7b7a0e5de1a858700fdf3), uint256(0x08448ea7e8d0c0856e5f4c872c92be5df06385e69c1aa85088a477ba2244790a));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x2cbbaff85a2c9462f11c620471191630030e19db4752ba387760c754a306124e), uint256(0x23b20914ca9b1fa1000da915e687b307d4995c97a812205fd6081532b0ec18eb));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x17598a3f3829078d125d85a3f0a90c2f8ef7727fb58a90a430355135a2fa54ad), uint256(0x00a5f21b496d12a7d42b5879bb1ae813a149f92fa81436c230561fabe616f124));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x196c2b3e0296c20c78d7a65eb7da51ecedbe8232d7528ec975cf23b6dd57501e), uint256(0x2b7c7a5f2982b668f759914acd5771d3c4369dbbfc8e80209f94205479b9cc1a));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x19209f92f8451f5220c7cc42ada866a90d7587aec8438dfd6c69a1a30e540409), uint256(0x124a4dd0587176277afa416c34245afe2bb15c181fa06a84d8f1d20a3b87f7c4));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x25b4dfd695366e62e5097ea214eb87b8b2107d7864b947ad25d899bef4f4730b), uint256(0x1a76004be6d39a4ad66f8cdde1cc89d734a9e5bc04fa6e16e46a97dd8c0d342e));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x15a167db4dbad6e1d52cf1a46b4d68b0ac78fc42e07dfd2001d96ff8187a04e4), uint256(0x10eebde6a0695f7d9151f0c291f852e89b30159bb51040ee0f34c8a44c6dc223));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x157caed0987843ec916e3315bffd146bb92b30ebe1e656f21db9a64677add406), uint256(0x16400d571c525f1f71465334a8289aeb6244b7b78f6b500562df72dd2e8e42af));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x19d1e9a1875360f15109a3a5df7e8dca927b66641097ecc230a01ff6848206bc), uint256(0x00e09cb289cf8ff10de3774f9bbfc0a450a843f19cc1b3f46cdfc29f4b481ffe));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x07bcf317c1819b8f46c2d90836a877c33fd4cf096db6182799d4a74593462d9b), uint256(0x06752c1b8fff13a4a70e1cf5d308b9e1522b5539631445116313df05b604498d));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x24a05283e0f71905dd0768f130def6e58c046105c82ee5ba33252ce63f49df5d), uint256(0x0f50fc15a95b34b43595ab5f7c0af512c77e0a9a0b8c925275ac5550510c91b6));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1977c0f27f6f23a508bb42f3071639d36baa3a2a9d198814fc2f634d98af7852), uint256(0x194b527af2b533cf594ed49471f64a570da97c77e1a3fb16731663610944fe33));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x104fcfdd5266ebd85ca9c8c257c888eeb2c58989096cf8625c20c5b31b84331b), uint256(0x0dd8baf86abe1f06d1c6e2ddae52c573dc1bc0f58686f5e69c7d19ff6550e9d8));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x09b2e42c9bbfc856fc87b235c2ca55cde8ad717299c7aae31d783787b52d6dfc), uint256(0x2fa5efa81580cf28b00f5e51401968d272c99d4f7c98d2b8b83aec5d09ac6fe5));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x25c8bac1e0e73eb942cfc947daf6bd8d8872b591da2275db542f655dbeb7fbb9), uint256(0x2cabfb58c816f2269fc22c32fd68810b385ee6f990c1f6d4a7b5efa2a671051a));
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
            Proof memory proof, uint[33] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](33);
        
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
