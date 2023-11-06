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

contract MVSC{
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
contract DVSC{
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
        vk.alpha = Pairing.G1Point(uint256(0x2f7cc4871d47ba51305bec7afba92b69155eceda1b7826f19273ed9c165772c5), uint256(0x0be4c0095cfd30e0978df7ed524f06456e7d7452c98f3b8b6b7a2b613f2202ef));
        vk.beta = Pairing.G2Point([uint256(0x14ad3058d3f51941aa01fd96739959dfbeeacf8878ff268b47cd5c62a0653672), uint256(0x27bcc7f97d8d902b044addc5ef336fc8b042111968187259ba6e6bbac3936ab6)], [uint256(0x26996fd4ec2b0bdd34c8d2905322cac0d4f31211ba46e7101136b1a667005570), uint256(0x18b8e1c6636fa3b41f2ccc795e86a1aecaf37cbbfbe0bb62ef5f49a7a8dc380d)]);
        vk.gamma = Pairing.G2Point([uint256(0x004104a11b16e72de513d4dad98e4f485da8882c2ea4525460058501325c602d), uint256(0x21fc376db5b81c7a87bb79ea2ef1e03e721941fff9411fb22206842af38c2767)], [uint256(0x2d38030eada39901b92eb67640700f27094603ea61eb9918712a0d5d3a466e95), uint256(0x27a2bd3418ed1c0baa7ad41fd778e428e9de76bd1124fe6c7054f8ad955c70f9)]);
        vk.delta = Pairing.G2Point([uint256(0x0a84bb2a8d10e40c3e24c43d4f01a372bce16791bbec92634eadcb42734ba276), uint256(0x1db3e616143f400d832e720a8daf1ddf6a2657d931a17d341315caee1d1ad2ff)], [uint256(0x115030a2baf1a9d506db4462c3c6bae937bd0e93a2dd66d044f0139651b7a5a7), uint256(0x2efdf2eb79c053cb33cf657322c02cfd29d232321f9bbbda4e52f83eb65060d2)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x09648e2fdcedcb9e862240b9cf6744a3da91751433ed39b6e3daad77aafd3b19), uint256(0x28828158f9e1f2bbea0e8e8bdf65217422053ffc086def2f15950dd6c737cfbb));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x216cfad912998fb90f6d9105c4c19eb3022d58c356da843fce30ed3791b56b35), uint256(0x01a17f21383da89d1ae69df2326f63e1e76b6247e6ff50022c18a751069adb85));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0961f7315348a2856a822ae5910ac00f4d32e8d74e7b394db82068747a364717), uint256(0x155941d7150c7d2fccefc359c57e04485971b407bf51f2f6a4fd022ca0b6a066));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2933174f79cf5cd4185c025004c457f542374523dc5b578f9385ad5917816986), uint256(0x00bd19917f759168c632eecfff7041dad7babf992bef4fdc20c3dae2e9853c70));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x143979cfa6481656ff62bbebdc4da47984384f82b78cd4b0f075372872cd621d), uint256(0x1e0859ad3c2cc052758208a22af13e1a8aa640299e132815c9fd27e63821b268));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x095159519bb7df8a36b05f89503213942461306320e4df1b827835164f84b45e), uint256(0x1e29cb3b8cf5efec8ea1d835a926a033e2a29c9fe8a6d03383073d63bfb6bde4));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x09db7702deffaf3579cad3333be628d240efaad1841930315c8895192233a85a), uint256(0x1589f8634ff555bd4148f395269045fa0422a9b5a08e365129e253f8739bff05));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x1726944041ae45662427fcc671c29ce06379d89947ba47039c3764ebe6cd0415), uint256(0x0622295453494f38d235632822c9596d6fcc0e1663760bc180ada8ae16b5a33f));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0f9fec7be17865f31245c490c9d376401e35753b902fce9f93f748d21fbbde25), uint256(0x2e3e9b3c9a7c153a5b78f559bc3b63a912b210c39eab73c271e08746bf187d32));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x148c9c4262640b47cdea4e889ec73e9998910dbe157a1d5f1c194126ddf44abb), uint256(0x29e0841cb274fe682f751533c7d4644201278f00189fd8b2ae18d475c3b2fbfe));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x255cbee46fe854821e293207f27fb40eac770be0c57dff78338059a85ff614b1), uint256(0x29f4bdb16847e3f1b3ad77353fc3f0b481df0f053ea4d9af72836b8266beac55));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x08e2704036d7755e9cc7521cb541cce13e24ef97b6b09eaeb88b775f387fd9d6), uint256(0x2b47d9c4112402b0da278428bc9da6c86e26033914d440c88f20697cfcec687c));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x168446dc728ae13aa9e1dd82a74a81e6b1f4e7998589f3e51e3cc09000e2bc6b), uint256(0x168ab62f8fc86f1502f36dbc249540aab3b81c75087db8bd57c14e3de35a0517));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1aba2123a11989a6e2f30b96e86b91d6b27e1ce5d4f4f06211121bd1eafc79f4), uint256(0x1c00d98f953a0dd4c790ac4e4c4f41cfd340b315feff83a4fecddd9e1471084a));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0bfa97f7d7930ebc57de765050dfdac319e902422877504e165a3b6ea58dd9e7), uint256(0x2ae18b9815f3d62546df8f4c37452a3c33148f1d368e08fdae34380d8172fec6));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x130448ea16053e63e834f5c9af15b9e16e305b84fbbf74ff0e55eb441b04cc88), uint256(0x1d279eaf78ee6048095035cb1eb4abcf9b4a1a3f127f21cdb1b4f083b6763dce));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2a35af0229013702dedabfbf5efedd232c24c2353e127275d6dde1ce255d4c9a), uint256(0x1818024b8582a50dfc5331754234bbfb7d09c0bacd15c719324de5c336226d47));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x0af33703d0a43f9e19608db30bb4c0177f96282e3b47ecf42c13d5550369884d), uint256(0x22d037da23329ca4a00b71359cac282605eb31bfbaa9027337aba336a4078567));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1cf132559a26d08a69d365b7bfff14135c93e8f79af287f2e0690cc6011df8a7), uint256(0x190e52b6ecaa7f05a0642e83584cb92f03c73afc63181a934f3d43d615ba4dfd));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x268b4d0dcb3c440897e90cd69a2d9e106ecf3c5cb698ef379ca869ed123c1b98), uint256(0x08fc9ee1ce2a566e05814ab1bd2a88b237942111d19095c21686421e85eec015));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x18e7eb3b326cff1b77751ea7de9f2e9c7a69a35fc790aa6ceb5a527cde52825d), uint256(0x13ca19964fcadc29bf9d8e01dcdce1467e9c41a8cd36449c47bd95decfc49f58));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x26d0652df56647bc26cc7a7ef8f102a74efb2df6a58a12fd388ae64362f9a968), uint256(0x2b82aa3bddba67ec95ddff49a33fc50f371ae924224cbb6c0284ee3babc6432d));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x2b5e94fd3c2ab58c5505b0dc679eab29413450d77118c367b6075120027712f6), uint256(0x07c08f736de0534c39a1452f13a525a03031574d5e11b7c903837277ed07ffae));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x00fc61ac2446296da416cef34cdf3876039d9ec9064e286c425f94f12aa41154), uint256(0x29c6cbf818c3511991fb2d8598e58417c5817a1431d407d02cb360e72d9d5766));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x21172f28224c0b58c238231ce4c145e0292e8660df28ee25171c69a6f05738b1), uint256(0x2ac3dfa4bf350feab48994b2d84cd4024a0e0e95b9caa5da39669c069c7a678d));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1f7cf23dfcf3bbc1957610fb01a19d02922646abbce96b61980c8e792b932526), uint256(0x2180858ca7ad6751c3a44b0c2662fc06eb8e88fbf6a75a941067928b95d029b6));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x13e9b1938b6c77d7f290aef9ef6a5b917e9810e01b4ed73b771e32c780acc272), uint256(0x2a4ede4ece6c438cf038e5aaf1ef0801183174cade540b5c0d00c11b15f2124a));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x198f2db6826c88e68f68550a79deb52bb7cb709ec11f354414ab16f15e1b7918), uint256(0x15196a142341504d306327d16bafdfb3dc2a3e9624ccd25bd333bc4355e19451));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x006c4fa2370a243c9e67c7eb34c5ad851d059f1243d5ca9e36ccfcc228c691d6), uint256(0x1444c8ad3638e2228f73ace72f0d72188449a8ba302ce6ba0f90c9ae5bcfb45a));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x082bb778dc126a8aa3df78a9099c5bebf2cf798912c3381570685f78556e5e54), uint256(0x106af8e5a03b8acefd4f265dd16dcb22603301b0703715c7a05d49df838c1213));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0ff50e9e3aa3f496c270f532a8e006ea403b44aa78940b90793ad0c1d183c79f), uint256(0x0df0ad8cbac14dc741bde1288de570d8e91ebcfd943af2fc93dfbac277b33afe));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0d389b6a58cd027fc913d805149298114bc1116ef112e5d1b3b9da70841cdded), uint256(0x12338936fdea72a9d959c953fb97f16695af60662ebf248bcf14c4682919053b));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x032b9bb4373d4a2df781a5cd7ce8208c5f27789c685f02cfd0e241106531b79e), uint256(0x273781eb207fc241d44368c4b5d79c7f25002faa68ad4cee054301f1d2a1ea33));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1f267b4862687d25d0ef5d537d9cf82a5a8f88015bb23380fb57a3c769d52c22), uint256(0x1754b64402d844285330c52d01727c3037a404b9c55cf540e1f69c99a13df39b));
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
