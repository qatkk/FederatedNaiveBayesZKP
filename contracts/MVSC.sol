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
        vk.alpha = Pairing.G1Point(uint256(0x0e2cf33b96d0f601371c3fd23de743fd8dd384b7a84ad7f5dfd0f3e287abb47a), uint256(0x1509109b415a65f729029408da50807f989e7b853879a3647990549d47220cd6));
        vk.beta = Pairing.G2Point([uint256(0x25bc067cef4f095d81a52e3408405645624c352104fe063f5bbe8ccaf58b25cb), uint256(0x28be428fe463ba4b51b6059a4a08181d563e7e66ed336905bb6374655df7cfd7)], [uint256(0x2c4d24311af76401dd6604a803afb6a0e7611937ade1111a30e147a4941b50c0), uint256(0x0daa01cb712f71fed66d19e6af6240990b719f8d53c82e3d4db27effa154c212)]);
        vk.gamma = Pairing.G2Point([uint256(0x2d77877c846a5bfc5cbe8885dc48b022658ad4580f3a6ef3e08b3373d3731e3d), uint256(0x1fb8489aab97745397d6e3918d30238fa20955126117c12b95ecd5d0c71bb677)], [uint256(0x0de2161af0025d8fda46583f8fd37470e5c67db345a95fd923610eac1ba443c0), uint256(0x18fd03b1260f5082d7faf9f0d2be98959e7070974accd0cb57e6a3295b63abfe)]);
        vk.delta = Pairing.G2Point([uint256(0x129707062ca914b89f0a23ac87de13bbc5a9cce855c21bec046833741c26b403), uint256(0x04f7a6af543077942450fa096d0c75872050d2d6df1927d3680b897db76db1ec)], [uint256(0x26580019e3c7f52c1718647ff1ab4ed1d66b2a444f1d819c8d79b966acd23963), uint256(0x2cdcbec0fa877e9627b2abacb291f1727da27b1b2d6559c432ef4feeea6f46ec)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x108594025cfb1237677e9b041fc1c813a6a2d1d6d6d1d8268e923fc1c65aa9b0), uint256(0x09263c28f68cc2ec2aceb1f39becf078919e9b190730e6c20b61d547cdcdfdfb));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x28fb4572d860e92cb27d3fc645609b61300eab360e270044d9a67e94ee5fea11), uint256(0x087283a35380cb50dbb51ec99fd6aa542528e43623d15bdd4deb23085cb2112c));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1dcba2a29675e42a23bd3e8c2af434943f83fabd6c12cb4f7e12ab1304441628), uint256(0x053b1811f821368e28ed6815e3b04ee4cfc64fda91c8e71882647faa6e89050f));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0772146a3c3e459c69886baf85eceb1808120a650cec6c8ebb2fe72c2bf55cf7), uint256(0x175a1dde021a145c80c9a7a2b528c67f55efc0724b88b7d969521c101ec5bdcb));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x0cb183af49cfdba2871ab2dcec917e1b31a728e54ac02430eb3fbb5717db7983), uint256(0x102e4592648c756beb0bbab7fdb2d0000d6742eefd11eab16bffe041991bd2a3));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x075be2e79dbde6dea5f9c0e6027d3a111b649701c7995207aa32b5fa9ce79ef1), uint256(0x1b51b2f0ffa41481c5728b1f5bf3fe6b53e1cfdebb7eb05c88f3ab9b4445bfd1));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x030c6e513e161904d82f13079df4586565a41c89f37bc4a4114166bf470a1996), uint256(0x14ec66325ef8d4fc5527abbc83dcce71cee1f87b9f995e3097bc1d35b754da73));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x21b1afcdb77ff294fa0ef473797ce2966a023ad5859facb3129444df254c79be), uint256(0x218049078886188c1653a3438a2f17c522c057e3b37489aad1a5199001c8d6fa));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x000416ad36ec4f4ea11b50b76a3bef2d048ecd71cd3b0dbf032f5664229a56ee), uint256(0x145e50da616d15c97950727e98a4b8485f381111639ca7e677137e3d0140665b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2e96f4da4f478b392c8521651bcdbe66e4aefd0c851dbcf0b60214f6b8ac1d04), uint256(0x305f462bbecad21aef709b4b6d105c2d803fcbe505f956bf9c7f4a47f1ef6618));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2764fef5a39d5e4f3a2fed7dee06ede87b061215f05812d631ca80be8660f962), uint256(0x1aead7233124635e40eaa59b4069d29c133cd05e2373063d848551be221dd6a8));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2cfd46c6da48b4e5fcc219339f28138618271680712e0d86a969d16e7ba35768), uint256(0x21ab99f4a9ff353a95556190e4caa678a38bc2b398a735e6034cdac5e7301ee1));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1fa5c0e7405071a1de2ebf8b6ba4bde92961a3f9bbbaca42e7a6b4afdfa294ea), uint256(0x2defebfa3a498d92415a5137fa6d9c4c5e3ec8b205a4b0b571630a22062fc7df));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x0ef9ea5279f1f1f7af000d2678c6cdbc7576bd18a80b8d97eb84ef5857a41755), uint256(0x1b1402ab50605c1a0286dead17867b53af73f7d74068fab5d624206f7ab3926d));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0ae9c9ea03ad88834636f60f5bd70feed450604759ff927211e63bd9299ef6b1), uint256(0x29cc0c348d51ac95148849d4ecdbea0b31199ae98a0031646e074fd884de049e));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2b06f431817153abee4907371b933fe4865003fec66f45e6a7a8f84d9e722cf8), uint256(0x197e19f95c1ff13f10d7131287098a7d59c50ba6b8a80af250dfefffa550e425));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x11db11b1c28bedf188c7b7c36ece94098b8805848f06295838484ede94820f80), uint256(0x0d06d1406135d58afc1e7aa65f022cc42f255437cb799efc7a3c3c86d83c9e09));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2d5d165fea10df9e2445baf2af452c83faca2f75eab991ae0af4b05e56c2d6d6), uint256(0x13cd6bcc77e7855e91363bd0db6443365e60ec7f407616151f198a57507b5989));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x044568ac4350b0b83b9832e7b6ff33e3b84f437dbb759b3ace22ce9dfc846b21), uint256(0x193b03fa387d9552894766992c8bb45d483dff992da37c12c90bb50b4efefa58));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2694196b0199ae14029267af8c8f353ecce099cfdb9dac3b11e6a877a96e5165), uint256(0x297c074010efdd3bd7fec717e7629e07bb7e8d2df102299e31758be4ce783009));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x0113a8e18a106dec71f403035b8d7f6b3ff928efaa96b3dfccc52980d49c52b6), uint256(0x2ad79f854bc5bc2cbfbbe0d45bd6c0a1b8ac4361dedc8b6126d8b38328320dd5));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2ea4717eac32a01005f67ad694948a144836bf953bda87fc98eae161a5d74d9c), uint256(0x24c6f7c0de1ae7a10b2d705056d4c0b11972fb420f2a3136d4dc94cd4ad63c8c));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2e8130a1e6364a8230d26790bf58393923b4704d36997f4a18ad31e12b222623), uint256(0x0b8ffb4f6a5592269f63a17b51d77a6aeffa72272d1dd008e54468f7a10cc056));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x07f4da052630ef04a1836395fe427f90fa4b7e0d2c95dd2caef9cbc0bb610817), uint256(0x2e41fb3c9eaad1cc292c68076aaa17dd282638ee57313f7d47e38d887c793188));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x22a9bf74fc778e4ae0168e11d230103a53d7a77d0ae2129f8d51bb2c66f14adc), uint256(0x09786a6c7b6bf03ae6c4ad52b2c6b9531d815cda62e5aa9384c4d3701a75e91a));
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
