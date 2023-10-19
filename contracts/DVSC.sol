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
        vk.alpha = Pairing.G1Point(uint256(0x2b8f808f0c59ee9e10bed4a05f4e860587a72a60892744ea279b82941709f181), uint256(0x07bc556c891897c7cb95129d12366e11b64bc0bc1a7952912ac93cdcf5afc763));
        vk.beta = Pairing.G2Point([uint256(0x305d831804b456605e37e9844d7a613cc8bcfffe9e8a23dc684ac3f82bc4ee5d), uint256(0x1b34a55531d4edda714d12fe0f3c35184c9d59b6e48839066517f986e2995dfa)], [uint256(0x0da7f0515480703066d431bb4a6bd8f8241864eae0ec4a5183486db75a312b8f), uint256(0x00460c53ea9f5a8bb9bf37e6716eed7f74199a54b3ebfd043d3954bb1a8413c0)]);
        vk.gamma = Pairing.G2Point([uint256(0x1950004673ec441581f945c4604e8f6347449f56f399f5424219cc63599af4fe), uint256(0x268a2b6a75aa656f8e4c8cc4744e467999ed3b2e3f5af2858a7a9c09b3ac0ac3)], [uint256(0x1facf4de23189655098e0907bdadff12f0a6f752bb088688a68593fed9317e2a), uint256(0x2abf066cf0513f57f8e51823389d61405a7c3eade00bd62b29eca6892ea292b3)]);
        vk.delta = Pairing.G2Point([uint256(0x28f6e07e88c6e6bdfe9e5f7f18b8936591913e2d937511b22731e3e100b04414), uint256(0x0c9f32d68de80ae7b1d78be828dd72a1ea0171273b924c4fd797d0af5dae8afa)], [uint256(0x0e5521dbe05d26ce36a27c3a35fc748fd8ecd3f805e1f0f3c63a931cf48bedae), uint256(0x02c0622565578621ddc7f7969f42e0861a50a5ccc4a512224b6795336ba3261d)]);
        vk.gamma_abc = new Pairing.G1Point[](82);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1d76732270c37e5cc7a7dfb6acc64751c737dc9b6cbe865b9af4f19f1fb87672), uint256(0x201e3d4f7959cec5600499b924dac2d507809954c55ac9067124e866108acb65));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x28308b88c19b06bfc35d0bdea051a618f56d12e52ad99e1565812aad5be6a059), uint256(0x0c017100b5ffce58353e7bb0caf8a5e7c15bd17a60b043908e96b7cab2fabe3b));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0651d224ca61db513cfae371e465454d4adac72cd7f61d2d8a9845137b5e170b), uint256(0x186797c2b751b47e435fe529029e25dc60efee15c207da37eb9382f986930c8b));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1bbed9ac9c10feecb4fa8e44f5617a7edc3d6db5087f88983fdfe4ae2af61e42), uint256(0x263951a2a6b7d10340df990b1eb58a46439bac9480df35a9a6ec44ee180c94b3));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x06638ae27bca2ac943a580a97e48ef939909f975aed6ed7adbd3dddece22e80b), uint256(0x024f50b514916c08d177fda5a876af3d2839ec4617ddae958a91c76a8b04aece));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x01ca5738dc18cc0af7b08fc71aa1868c35aef50f07574b31b8d42f9198019f9b), uint256(0x2d7ee3443ab1b2ce564eb8dc92d949c37040de18606c14dd93ea1fe83ebd1d0a));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x04ddf1582c4f7a3f0d60ee6fdb67172f4f725e2e2f242fd79e0e787c1d9853f5), uint256(0x05180499139f73d43683ec41066a8cdce10c8c5ffdf931a6a42f144571807853));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x00370ded6b5afc6c766c6b1c31b586a988e5d2d98b44c98b511763890aa66799), uint256(0x1190063e48db1aa62959846c77ae6698171155f6e8874b5443615e9ab3915f24));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1e486adbe00c33a19759921894b6a6597be16128f02261c417cf09cd7d2eecc9), uint256(0x161932edeb7a2344e317bf3606534769bdcfa34e0145ce1ae587845d4af9762a));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x14fe2b6947e472592748997f854e325098f2aa5ade99d05a704afcddbf0fc8aa), uint256(0x0fdff3a959a4820c006a68ac1bde9e67e021dc4dd7b4ebf359c8fd827275b428));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0b2820941c86160bc9ec41a837f1ec878ee576021127e7079de44992c7261475), uint256(0x0439a36edece22d1782aaea533850d3c8125931fb1c58a74dfd610ae93e828ae));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x21beac1ee6b407fe70285b9c80cee5a7445c0dedb17ed50827949f17faa5029c), uint256(0x27c75fb95f41acb1386df7a3d6558b63a0a254fc6219533a65efa360b0fa478f));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x12ed5939f8b4ab4fe9cf1945c56feda13ff44b30ee91d9d974a69799efaf41ad), uint256(0x1d1d40df32eac3c51382cf6bac0832f59cff77e378c7477ca59650eb57ff636a));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1bc46d057485c106d03f3b340b4ffcc7f590efa46368b40cdb8d073401f77ef9), uint256(0x08d2237cb340f626ef41dfb195c65fb763ccc4fd5f8ddec89caf506bd5ece9c3));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2e02cf420c63657dee4169c9ab72e648015262dd73f44e6ba5afa8416a1d333b), uint256(0x1497c9e77fb9958b16871b12b91b468d2bb0ac43bd8c4b7639a70f0892d510cd));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x180b9304376f99433d19e1cb1ca92d0a677d33db1be944f543255aa19b5641f7), uint256(0x1e25b8219732a24fe018b05179cfbadfd7d21019ba25dba201c2956353123145));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x1fe9f70820764e50188c346b034642ddc01ad82f3c09a1f98888c29982e9b7a5), uint256(0x0dc8cb9ad2f2bc2d00e81d9283c15cd9d25a005b0b43a9694d24b4f27ccf5a59));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1cf298b87b0581894bd4e16555765873ca7a0e1e6886f32bf51542ec466596e0), uint256(0x14fe1b25c66b9f4ebde4ecea93e666d18a1bdb347212d4509c3e2f9cf469a088));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x24cd0d668e93100f41a4082cde60b23485a10a30fe996f826dad5461e5e7afac), uint256(0x0ffc522000e19dc8ce7123e342bf50ea2cb9dc1220177cf0435354b1f499a2bd));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2f3131dad86e468fa56dcace00127883e33c1d37fa0194f17ccaaf2f5d7ca366), uint256(0x224c8a9a450b06896205c49658b3a4a3ac18374cd3fe24910832274dc3d11169));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x065998167e81f9f5c83fa57347d83098a0daca467d4768ae2eae85b3ec78b3a2), uint256(0x29f580fb0c9dac3693ade9afcde73035b558d3b1c8345f64766b166d3c400b63));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2012020be15e814b944a26d3109479ee28b0e85f3d14704ac5d141c8a76a547f), uint256(0x1e13044b759307c725028910f7f8d749b6e2e2bfe6640354e946ea9b58af63f0));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1da24732e012dcf09d855cd8c1fae841a94c0920c6ddb7f9a7b8dcf27cab2172), uint256(0x046cc1a06162148f2c0ebe318a9187ba53b73e47ec773f77b09ce2558e892d5e));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2f2d93f8d2ad9323ad2c4c0cda9659bbc71c8050318a90ec9ab7e81ae8be6d01), uint256(0x2cc13cd666348c7a66fae9483381331f0edaaa3eec8b8552c10dc0ecf22b46b9));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x2b442d530049352e5d8e38b0b7ee03ea8c7dbbfe0bbdc1913fb2bf87027f3bf9), uint256(0x2bf600f16a4c3dbd643ac6f240b91a63c5b62f8b68ce723ae86610d0b1a5c202));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x27e4ab12fff93a24685bf555bef392b6787a01e18080bc75ba676c525b9afb4b), uint256(0x179660777bd4eeb680a0e87b5dd4d0bde5fb80c87edcd034aac752b14aa8c383));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x18bfe30a1c8eb9baf2c52852dc84d3b18f39c9bb3e853a27948c3d4d45987ac0), uint256(0x2055be10368ab0579175012d4a5296410c53d09fd6c1ab31f8c30141a1d6b78b));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x23745abf9cf3730877a814e0b85e5eb2b5607a4c9e2fe369b0c543a7f6b50c15), uint256(0x1d81336ca41d38b9d4dc2c22d04e4faaec6e7553cadec4cd287c5df2ba4838f9));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x22afd2466fc028d58013c8c8aaa2bc79bc24515637974e4b22f289df05216a84), uint256(0x0e3f24c9c6e05669cd409b6ec17f130ecbdc1c4cd30517ade86d5979712a18c5));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x0c593cdadd3a81b4dbd39ccb2426fdee09651e20eba5df8f1ac07f95ebf4bbea), uint256(0x206da793a2e36d0cd2844643ee3f1c842584aafabe759cee968dfe90da5cf24a));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0b85adf426d0969f617275f353267a8467702eb9e59ed21c41c54573eb354171), uint256(0x058835246dce9b8b22b63225c3448623516921708518481715680deb56e94f6f));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x065a96a1fdbf31d7c9454329b46579e68d776abf53d0d9bceafc0c2c07ac7f29), uint256(0x1244b1ebd4a566accaafb0266c755e2050a317f7c41022a15872d23b2766d68a));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x10fa161f039ee5edadcb5d0f4239b6081b84497a61b9c35a52731ba5eb0326b5), uint256(0x22ad07eba118e35cfd6b85cb3091e2b3dccf77d448b045bea9de2ec1cdc87ea5));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x0e45145caf15f6095797e471642fd025ccb206896ebd053df144251f9647a230), uint256(0x03cf5db66d08705e033d3c83933ea4b7ee1b82aa40307f4a1dec9b49ee05270e));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x2d4eaedefd1fb7bdba4e0025449775656393fd261a7e8802a1cc85a0db248da8), uint256(0x261c6fa7f0cd622e19d7704cbaa5dfb2fc9f9192a1529b80ec244bb7b530fab9));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0c9fc9581e737ce7dcd32d31369d0eb3918ae4ada30af25a4b42e87d1bda30d9), uint256(0x14203ac8e540474dac9498737c17a4e632a6cca94003bcf37216d670a5b6a28b));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x06597eeeff3138452891433d24881fdf5316954618c2f996b21b4600246a94fd), uint256(0x1164ed7d4504190464ad846a0dc582aa0f91c3b56274501fbcac1447f437d34b));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x25055d5c8721c57795f1998879874a403d5ccb6a57293eb96f4b31743cffbe77), uint256(0x2a83d717c34ee91d386b8faa4dc633cd9ed3433a63005c55f3f6319fce7e49cc));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0deb2242ee918a981b71bfa9af23d81c4471f5320517945f5d54d5dbc3ebc3e6), uint256(0x04773c22094671de0c77cd056b228926aeeba8ad9127df5fe1d5e8ed93c1fb5e));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x289f3d488acce2727438516c22a23a9de5540ce926456fd0a4aaaae8445b8499), uint256(0x1b95df75164291fe0980670144ac88c44ae53901c3864e7c78b17f1cc43381fa));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x0fa7bdef79b07f8af2a962974cbc8bebc49f3e1705aefca70096065e0469db2e), uint256(0x247477255d906614c551c359dce06a5663e4c36f90f35e3800d5e57443d1cdea));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x036d9eb20c2c02d680c29f44624e5c01040a163409559c28f41d5634decd92a7), uint256(0x244f2e76644ecd74ce8c6cf9458a7a0152734697abe6fc6eb023315f86aaf5f2));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x28dd925a1012487e3330b129284b8985df802c9950895dc53d3b0f550cfb3015), uint256(0x1cfa08b7d09291f571ec72b5ddf4726c32bc9b05b7f20e8241144a3f5da51a04));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x16912dd99715463b89c023d947eaee1f178b711e4874d80627dd233c561c4e44), uint256(0x201fa0727f0b9b906bb1c676745fe4c8b3ba755e45fd8fa25c86274a4f14b843));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0700ec1beb95c56909fe2a11ab64b3f7c2347ea02ca115fe0304087e6a7f582a), uint256(0x13db93c7dcf9d175530fd059cb4072f82ac56779b5ab38fb94aca8af24e5153b));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x05bbd089ab2592f29e6a207a4af1fd4d980a1433bba652cb61906166c78a821c), uint256(0x2e5b1c0916b355dd09282cddcd67f9776daa7d2acdb8919c4e8ae153812386cf));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x24a8362c215e16882da2c5d18d4e425a893a5464b8f27d08bd7896dfc4bfc281), uint256(0x1286a2b8e4d3eeb5587b462f620ffb4f1f556d37837397fe2eea4f50a1c0bbf9));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2360ebaf387626d2087319d619aa8a3bc5f54b8f56e78e779c334be241a46b33), uint256(0x168e4c0315a6312be73f23a71867824a60c94605b49fcbd9eafc09713a06d876));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x2898ce2b1dbe77190102eaceb4719f8f0f2c9540ecb3772adcec447e36d7d630), uint256(0x079d9560cc79b9194651f267a5af8c0d43bf85d60992ea29db32dbe8b9ddd4dc));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x0b136e26436d50a70730dac1896a50e731887117c360e8f8c751d00d59d5fe27), uint256(0x24af85c3e9d573ed8c07ef56d9d68e95bb2241c433ff99f4fdc8ccec4b5c191e));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2efb37334e7207970586f439c6a412592a15e8f82bf0b722f7c5fe848c8dbf02), uint256(0x20fabe9ae584298ade6cbe1d0e39c96f2eff39932ebc5e60de25c900a6a1b0c6));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2e73b137f14af0d7611c9d19e6681e952e64c919f74c346a6660128ce9ef41b5), uint256(0x0fbf8f47877e341b3464dfae7a62c989761d0ec67b07233d72de3577a0413080));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x03add1009b0598190ef334e909e03473691f7485163865f8042dba3d6a879ac6), uint256(0x2f67d851c2107217ddc1a155c940d6573a8f8e40e9bb2ba39694675bd0589ad7));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x0908cd99348a0b6e6846b4b796b28dbc3d165871feb52c9a61d7826f724ff7e2), uint256(0x1ff0dee38287aef7cff30eed3e437dd81f085d0df92bb05dc36125d5f7295ee2));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x1f2360267115bae607b07c4950e0b35bbb69f4a651da77345bcb08b64d7a6c1a), uint256(0x2b4375c467623e21ff1afc1f56f7076cb6bd9461985fc054ed8c7146482a79c1));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x11d94d98c73431f58d402298165f83db2c85ff9446ec69b75cc08b498ffdb43b), uint256(0x229e493e7722e4d510e2f7fd05109e2f4ffb1678ee3ee95bccad5f964a5b614c));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x171c671646eb833b6140f74b5e546de3a2f4b11a9b713c8ca22b6f27b22b351c), uint256(0x0c0c2f87135b90a2d9340d3ffe17e0ebdf7a1bb994d342b4ed367752c1f015f1));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x159b3c1b44e21977905e6f6976f447b6cca3da2b9af8d5f6d772fc9dd800d8ad), uint256(0x3062db182d46ba4ce01d3f0bf5fa1b36f1915e1bc9d84860d33c2bb73d814536));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x11dd99eb9a154704ea5e77c01c7688d99b1168aac81071d51aa7dc6a3910ba02), uint256(0x05ab954bd8f0387fb1c80731bd2fcb24b35d880aa0e80e1e0cf6476700f016f2));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x22c7e326359b26f7dac14787b5816b29fd0268454863d0ccd64c3fea794d3223), uint256(0x1cf70fe29210d197744fba44ea28622f5812c048dbb6727820189575ac6c79d2));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x18128d4a2b0d46cde262f7aeb3706b364090544308558881d94c7438f0b093e3), uint256(0x093a67088c267ccb6d481fa3a7a8bd2f2a55fb2c2d679db56ac585bbe36e9257));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x17b6fa6da550e000e7f2327a176e18abf79932a06af0bdc2a484620b77185ad2), uint256(0x11d93af1ca4b36487a5fc9398fcaa2e8a46f891340c7a00442c0246c0118060c));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x25c8c7a895adbb8f8347bb47d6e43a390329a5d40cb7c1fb3215556bb9c43a94), uint256(0x261412caf090dc08f348dabac35e3c55886882cd85cf815c517c46f1ac890ca9));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x0bd4c889e2db14fe42f92c3983c4ce98382f567999e90ebd72af1e78380622f4), uint256(0x1153df892b935130b92b18a50f47cd97aea4d449690b08537b7f2e8632747cdf));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x10233de21868a0c36696d040d2903cddf3ac5e0a02a82621381f50cd8b368f66), uint256(0x23e3828e7c978898cfcecb3a76af0a885ddf7c6f9e7cb73c550e6cee06a0e7d0));
        vk.gamma_abc[65] = Pairing.G1Point(uint256(0x08ba2225cff2ad5c8b628e2db673e9b554983622fb3cb5167585b91c20f533d8), uint256(0x1b85fb84703a86cdf9d53b0ec28d2899ce6dabded3105418ffddc3c9f8cd011c));
        vk.gamma_abc[66] = Pairing.G1Point(uint256(0x2db77ecd864cb7d103d3ba4ee1b1c6d264e79b6b9a7867b37555efdcc0a1d605), uint256(0x069f490fa6416349bc9d6d47e713b411567dc65c7f295a34da0e4ebbc3d77ba1));
        vk.gamma_abc[67] = Pairing.G1Point(uint256(0x03a225dc590d5e3eafae5e7f568cd82f8cb9bbb1969beafadb56561e1dd23913), uint256(0x274be07467bc8c47b71d3782b67f47f6685bcbe4757c4fbd235c89956857fb97));
        vk.gamma_abc[68] = Pairing.G1Point(uint256(0x16303866c8f2068c4e7746ff513d322f410caee28b9a1a5bd2512698c8754474), uint256(0x041c1a58c079dd3d65f481a1a5a8ea01d340d94567babc20ff0f83909f0b7637));
        vk.gamma_abc[69] = Pairing.G1Point(uint256(0x2c23adee4fe479b2a48155285b8726af1e51e84a10d66d26af3abb8e0ba304ef), uint256(0x29505e352a6af4da55866570f6310d26d77ba863647c73108c1d125923789b4a));
        vk.gamma_abc[70] = Pairing.G1Point(uint256(0x0e36f03817dd036e7135f7a872b067084b338a5e7b4948a41ec68e710dcd304c), uint256(0x23b41cd480dab0cc53117a804006a82959a210442ee186de156e18b5a78adc4c));
        vk.gamma_abc[71] = Pairing.G1Point(uint256(0x1900e5ea8a1c7ffe465bd817ec2a17b1bc2812693cbe4e1ba17c36af7f28e0ff), uint256(0x07a27e20c229119bc5f772f888fd5166fe45809b8b0c6f47d0c83b25b7892674));
        vk.gamma_abc[72] = Pairing.G1Point(uint256(0x11bb10c71cd700a579fbacefebefbec5c7097c31103dc57b59f71db2448c1c59), uint256(0x04aa85d38e5b788809f41ae3b7fbc55692329aa46bb7c994e4bbc3d43212fe77));
        vk.gamma_abc[73] = Pairing.G1Point(uint256(0x11cae0887e98c8c0d7489057fab1aa996b7b48466abcee7d2194bad20abbcd07), uint256(0x03d4bd2c18b60624728b7df6d6b3df03ae194bf613cbee5a7757aed2ba8c8627));
        vk.gamma_abc[74] = Pairing.G1Point(uint256(0x2b80ba4ca6993ba1dca8ef569c6795681365475a834d815614228dc3823efd51), uint256(0x152a8d832a02d0ae6a0fd3b70c2b4944515c42794dd480a269d5c6befb4267eb));
        vk.gamma_abc[75] = Pairing.G1Point(uint256(0x1ee46acec9ef941deeb3d8fe335f93a2ee331c553301afb8475aa16010347094), uint256(0x28541391a196b5a902b2515685c607086bed508ea7f499a45ef94c4ee8799c71));
        vk.gamma_abc[76] = Pairing.G1Point(uint256(0x0ba1ade875471718100b34411ac48cfa073a5061576990a714e300dc5293d6b5), uint256(0x1ffcc0c40f91cd25d7ff95f2b1e1c9250a4a3b30f8e693e830896d3c11d804b7));
        vk.gamma_abc[77] = Pairing.G1Point(uint256(0x0db89d812bcd8faa16752413e7598077093c0edf5d237d54941830bf60162b04), uint256(0x02f71084266339307c9225de8209d07fe29df456fbb528dbccfc7f49682b31a5));
        vk.gamma_abc[78] = Pairing.G1Point(uint256(0x0cff924b4da3a033392ee7c56ae9e96eda31baf22772bab86fa2b5af546308e5), uint256(0x29f2f0b2b71a378fe64d7e88b84585cd8406a3bb1a878da876f868a62834347f));
        vk.gamma_abc[79] = Pairing.G1Point(uint256(0x1a7bc097f4863e13c58b1acd05f878806779f39dc6157c31ac5aca4b42dc0a66), uint256(0x03e3e3f1b34606c31b6490ee340ae8021fb6d7bb8e77bea99ef795caadd543e9));
        vk.gamma_abc[80] = Pairing.G1Point(uint256(0x21eff94e793e9fe7035d8953e2d88b74190d76d270ae14acf098ca6d35e0b9d4), uint256(0x1832d36da7ed48fe56af662d24f6b1e2e14b4bece892bce6f597663e785c6687));
        vk.gamma_abc[81] = Pairing.G1Point(uint256(0x0bb90ad22ca7971293a0788a31054168cd44c6fee5ec53eaca88a72661a61b4f), uint256(0x0be9e6a787182470ea349c52ccaa5bf4ea17156f35a7c134fa15851451720e1a));
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
            Proof memory proof, uint[81] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](81);
        
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
