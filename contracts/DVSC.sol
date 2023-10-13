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
        vk.alpha = Pairing.G1Point(uint256(0x2bb67f29167a914b03c69b8aad5970df78023cfd91a5577ad677271de06b4d0b), uint256(0x13c9c50fab2755366e2b8de201af295f64996cd30d1a1c7baeb745b1c62c6811));
        vk.beta = Pairing.G2Point([uint256(0x2542b7e7f6c84f432711b0e3397a1500989c3d8ee0ab7bd106e44078ce149f1c), uint256(0x12d3769c3a2d0eeb558ef2e88b94de6df9ecddec93fd449afe773948acc9ad37)], [uint256(0x2298cb7778d78716c4dd07fd9368160b0f9af1fd0e072ff94875730e7b511b9a), uint256(0x2333c49f0048e17c4c1670f747eaef01db154ad51a525bcab69691a59ede5c9b)]);
        vk.gamma = Pairing.G2Point([uint256(0x07eec83164bad42a1547cc93699dfa19af2a9c38fd907167faaf7bf8bcb98461), uint256(0x0d7b38fbc41a101547de4bf7a3491b62dd3ce11638be11c766176bad67b11417)], [uint256(0x0fdb76e698e6b9a8de83da93e7887148166edf819905d9a30658f4da380ae1f6), uint256(0x02f03656fb857dcc2b70fe0a289debc09538fb94d07db35403affe6bf32048a9)]);
        vk.delta = Pairing.G2Point([uint256(0x209ce50bdbfe9497bfe1ecbd15fe30afc29606cba096d37be50cda09feb74472), uint256(0x20cd59fea61661090d3d2c6478da96a718187bf9369db268acbabf19e36a63af)], [uint256(0x1d42fdbbab562bbc8362fe410b81d4e0de7515ccabe842dc7a8c4f035836f8ae), uint256(0x1c0bd86b30c369e5d505803c7af10e7e916c683bdd2f4beff49dcf895b9efc89)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1517cb769a25823fdec0d666445e331c7b3fe73962f9da8160cf816ab5a3aefb), uint256(0x2d4c49a6b36365e6d6170b24a48d7313398c538e0d045b6aaa9ece4812d7c2c5));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x049371186dfbab02f1e5a667d56dea886209b86cf7efae28d02faa01a8b26e15), uint256(0x1a8255f3bbd8f2002738efb2357ca8c715a536a16d0df7a73a77c413259047c5));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x306026b09656fef0b6090149c56c6f7a7e575f0a3e22780d325c487d8c255e3a), uint256(0x1e3757bc89f9131e27fabb88971b04c7898d3de25231d8baae90aad2b430b2da));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x2cfe79f5af6530940a3772db5365b445792e007d7d9ed5861f72244d9f365217), uint256(0x14c2a94cf6a8ad9be11edd9b2f71a4ea25a4c30619491e5b4d4bd92997ae2893));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x227ed005a9975575d504b709ceb7b828ef9f7be3fdf27b1e4f98378cbd0be282), uint256(0x1cb6ef8899baa1180a30865a730a1c92506a32c0f550ee2375f407074242e918));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1f969ebc05bb91644dbbd85c22d704f0b7630727ca24ceeb452023f2621e503b), uint256(0x21777bb9b843210215edaf796e2b6e6fcd2e017a773c5fd75ebeee4d7f3423f5));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0f50308469cf9973cd1bfd7779c5f744840e5461098cd731ea3ee8a89ba2afab), uint256(0x06986a61d3d5efce945d6a1302e2205b2d00918ea5eb57999528d50af3dfb3f6));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0483c37ee85561ca20db8eab507df36e7e4f82cb3092116798e66aa6b42bdd71), uint256(0x27aac1c4dd3a87dd597e75b1c47c70587c6cc4ecd8034618992267c5d29d270f));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2eca6a2ef3b1078f673856c11c752a9d5ae8f000170648ac79cdf0ab2cab88fc), uint256(0x2ce4991870989bbe447a4eeb124dd4bdbba496bed42608e69299c404234f9310));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1f6ad4bd48d5e5ead6d5bb1588b88e649a0a26792b589cc19dc29fdb50ee54dd), uint256(0x1b9b61dd974769eb23563e2017fe61771ac0178b46e0c7c8c9fb05befdf0f7e8));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x03bbb644d43b04cbd0ed3dc2788edca0faa9e4c10d5a0e61f9152c915c5b5777), uint256(0x151188f1c06bec797b0354bc6ca1096d77a5b9159fb01efb0dd5413bea47c07d));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x051562be9164e211d60f4d0ee6686a7235d147c33945fcc998450d92e534ba8a), uint256(0x2d07f3228b18f9d6824e826eb2c7728f773de58231559a59a922a14a62596ba3));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x00a8cf0675c863d293712e69447476920a986bd7032845646d81eb10cbf90e92), uint256(0x2a93896d37bb134e594e3777478f4e04eb3ab7e72e78cd5e0ea32dcc2cd929e4));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2a42456b8f9a8f1c682965e8002e613ffd7427aba5be5c448bbeddea67894e63), uint256(0x16aee652badfea6cd01c07acb6851986ae6bbf5b4f62314494aa161b69469877));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1d8b4596fe77e19d2dbb6c7e2e5ba5ba22bbedc2a056d05dd71374fe7e77a471), uint256(0x28b753a8e0a0bc1a2240308a407c2c7a9bc239c3ad93018da97d1b1fb883fc38));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x12ca959a9673fb0c605b630925e6cc000baca56051c4d390dd59837d1be84c30), uint256(0x191054d3defa686058f960320c6e42821019a3c8ed00f825f71b89972e3a008b));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x112782c9cb74c9262c3044552a1ad0c3454475af0086df050f0bfeff4a2a3c88), uint256(0x0f689d7e9f3c7d400a3d99f8b2294295f128f9bfd1120f431d3eb37454f2fea2));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x0d88f8c2ee3a606e1531dde6c5dcf657e364bbc4be399f1ab0ee5bebd6956c84), uint256(0x173dd500761fb23ac92bece019c493f979e235f8c3655b0ac8b0633fe475243a));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2a37ff8c8e3e387bdb7bc3cd1b5699d8ea6adef8775e1a88382f29c80d32a911), uint256(0x0dde7083da3fa1867d565468845ab2fb4ef34ce8a7e2e5e5a3e3b3ed3d36b292));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0c2e0700e603d2d6e5181ea4e2712e2d7942af6e57aade458634acbf5a022262), uint256(0x0ed66cfa115522601b4986e575086e9a400b91e786a944d49a5a1c3d20dc47e3));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x061a3ef2933ebffb0d1c92bacc7a6f942d3496b5d2f9d420179d76e0b10d1cc2), uint256(0x288075d750e3a16a08ade4dd0d40462d8472b511dae55d092f02cedaccd63a19));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1524c55b15ffff304130597d442ef82d94d405794182c1f8789432308a19ef3a), uint256(0x0328990caafae119eecd82e9e5e3024b134bc2a98cb6288b06726f9e21cbae56));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x234703ead7399c7b9e4c54a8157000d84e4ca8eb84a418bdb86df061775b0e2c), uint256(0x018991d4dec51143dcf14df9bbaf467fedab28dd7579102c3b23dfdc703361a4));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x03355d14aa7a28e6ad3ce21101b6e28dd959f69f7a5b706a74b1bbe06459e98e), uint256(0x20b38104acdd98539590a6cc3368ba57f0af640afd682dfd7e3a7233b8fd0019));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1c6f7f3c67f61997d9f704c5841bd848b7febe35bb78ceda5fb281bccb53fdb6), uint256(0x1596fd346975b7770be554a628028e337bce1191194f1cf6e0f935b8486693bf));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x076777f19833706d75f5c5d454d7caca6c1d1ba835993187a944a919fa4beb72), uint256(0x0900b771b22d70055e26d2feccf852ab4e63e03b65410477f427f7dbd4f59183));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2aa2cadc31147b9fcfb1c9c48cbeb0f298c5c83dfe9aa61bc882439585f7af02), uint256(0x27d43212075055218a9afe7ca704d18e15590007dadf609c7ba23a83ecfe578a));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x0500c18e33846cc0fd51dc76660d664fa992e5da5634cb76d414a463ae0f961a), uint256(0x14c7a169ae4bae697823895a69b2d51de80e2dc2d7cfc4c1e203818fab66b799));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x1705ebadc9433087e8dafde511e87e63c1a5e8f4e2ab0157a1c4a2c68ea49d1f), uint256(0x253e7583c7339bbcb83359904fcf814ad7b582cfdeea5a9663b0fb516c6b2b05));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x271883e4f9eaa9b1d7e75c60523fadb8254eb78ed2898243fa66cb53a3cd0c0e), uint256(0x063dac9b4fc0beaf120679c4c59e622e2b18efb179061740b3d03b1a8e5b1549));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1fefd64b5a4f136aa759cb4c15769c66aa6c7e9a8a16560439a4bea66741ec69), uint256(0x1a12a7551ba425d4151549c26f8b62c3026f6bc6c97034b18998fcfa40b998b4));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x299568b599f1eb133991a4308da461574f359ac06c7bfe68900899ab8f9b8be1), uint256(0x2127d4c5efde5bfa4f64d402787ea6929e04a6b39ea8c91df4e2bac4d584843b));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x04f4edd3b0bcfb93401f44ada2225278c80ce998997efda125be17e387b94e79), uint256(0x141d2a5fa9dd49d8b925dd5fd9c16cf08f52e0dd0b803b706fd0dae21e775635));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x17ffa3baa6f2c1a5ff83f5bf187db94b2990d64eff9ecb1f35ddcce9e0a729ae), uint256(0x26bdb5af039aa3beb44a12bdd1ab993e1a7643ee269d9284a8e6f56f5fa28fdb));
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
