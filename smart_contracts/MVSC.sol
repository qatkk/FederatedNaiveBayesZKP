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
        vk.alpha = Pairing.G1Point(uint256(0x14b45f3286fd0ec24374eff11a9db41289b6ae474f1f854f2c40c020ff4bc033), uint256(0x11345d709094f19f76332b3bb6498fe135c3dd471f19b8d5dc8e3c4a052661d5));
        vk.beta = Pairing.G2Point([uint256(0x1c790e52e71830c84ca5339caf955537b6789e7219e6864d84ac338991cb55be), uint256(0x1e5ddc5fa4b0a631d993ada88c87dbef9ccf11d1331266a9f8791f6f27299de7)], [uint256(0x1158793983fcb239e4dd45cdd060b4ffcb2c55603c2597e70f5e126f9e343dd4), uint256(0x28be68e131db5d7956280f3468463a150c7ff5478f84a968502b6ac45913bd14)]);
        vk.gamma = Pairing.G2Point([uint256(0x0c228d33539f5337b5213e9eedd1e5b0970b6e6dd7df5f1815f98907844ad7f9), uint256(0x25f1d57610fae8a937074d58c7273376de6be8f7ad4e43d62705a4333c9f0be9)], [uint256(0x17cac771935e493bafd452d8fc02cd20d738cb93be544a6639d5925f7a632171), uint256(0x28b862b6a7a948c413d2fbdee08c3c2aee97c3990e6be229b039da83b1dca504)]);
        vk.delta = Pairing.G2Point([uint256(0x0c55cd4253302fe0228b7b6c21203c4a09ebe7e2fc9b56989ba51985f8500a76), uint256(0x19694b9e79e72aea04615e8978ec19b84cb85e15c65906fa4e4c821a5f960031)], [uint256(0x2946a8f7dff4523624a88cbbb5ce876b5e1d194bf9142f1a22abc571ef24cfc8), uint256(0x0b8b892ecd25e96e93fd73256412d891c8117ffe061a7f019fe99b0778331deb)]);
        vk.gamma_abc = new Pairing.G1Point[](45);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x14eae84ed85a6321eb72a9572fe3837d0d66a12ed40a5aa72a144f27d1d9579e), uint256(0x09573384370c4e0ca98f2d93c964b4c4b6c65ef868efee60f61ba693361a43e3));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x10013be88eb118911ddd52e74587d9caa340a7faed93a99c777201a979091373), uint256(0x04a59b1f348310470ee2605166e108dc70912f314b3d00ecdaf62e47fa5f7806));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1dd04a9d3c0d398e9a084292344132bd681b8e7bfb7d9fa0cf2de26e97f781da), uint256(0x09380e2fb2e45c259ab92bc9ac92c2370d782485b6c3acc70abdf10d51250e0d));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x09cac3b66cda6a38deacdb0eb3c98d8ce78b236b1ee0e46964102245a94e0aec), uint256(0x2418dda87f06b74958f86b5df58d8225898974729f8c4286b9a220df5863fc98));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x12cf9f40bf083f1ee5152f212039f40e46786fccf5afb770edd991a51fae983f), uint256(0x1a9425f62b2c12daf83517327777c85f2b9425dd36e0bb77a9452b90963645c8));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x022f33734fe8dea9735533c87843b3a73ab442eeb0e4bc837ba4dfdf71b6f080), uint256(0x2df1fd6f963cd32be429f6d77cc960ba2594e0a9b6f3600cf4d876e045b75b07));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x18b3be6cd5b2cacf5c4f58d278c07ffe3eb98ba68f66376a2e6523d88991488c), uint256(0x2b6e13d92b63c65a5e58936d8c21cdc0b06f2e0e39a90d8320970f19234eca54));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x075ec997947e911e6ace286c9dc4fb6d69fe2560221673cf2637e17c883f9816), uint256(0x29554d220fd765259cdb8da40b1db265e2ac9b37a3edae2a0a1171e790d121f9));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2b1a5dc910ba8f92b2fe93df586f541f7fdbfd2cded8e8452d3ef9af2e571278), uint256(0x2be838d0dc135907a3d13052ce098d1cbfc33d17fea585347f6b8016f628f8a6));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2ef79dbf008ada4d713cec550e79fd08e3d45821255dad92f670f55ed7bad997), uint256(0x2da8f272f358ed20b42c1cca2351c366b120fbe43127782347eefac3407fb4bb));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1b9c41c187bcce83c1bdd7dc00cfdac4a951dc2b8ca3eb4b7e30fb30c7e0281e), uint256(0x11ed8b327076ec310c65403e06a0230d7db4cf86d712df50b57bbb279f2dc86f));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x3026f068acdb7f9225d494a147be1358e694803199af9efb5f31ea750cba12ee), uint256(0x1bce1699ccc62af9e2714d96f76dbadb5f632796136876f949ad42a899753b5f));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x29f335b0bf077e4facb03b888e08a77f70741496646f48831abf6f1d7f6b9010), uint256(0x0c553a5acdffb9bb23cb5a60fdeab49de0e372d0dcad23159281b9aad99a4955));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2e416a2779cabd2bbe55906d7f44544ac97dd63ab4c766c06dc44913ca6701d9), uint256(0x218f80f4bf1875a678a5f1d7fb3efce42b6ed2a4dff0006dffc02c9f20eb7d15));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x017edb8055572b7a893eb6f3476f963f5adb9b81c56eec34f040df87acba31f7), uint256(0x246384a0d9dca4cf6e585734a0c284caf68c38f093ba3e80114c5c40966f4fd6));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x257c20563f7e9a2b1939fb0c201deb72cc4837b7ee01280543b4818d58d10429), uint256(0x126a6d596787d2a499944ec5121c7082edc5920a9746268675a2733b1cb35bb2));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x22358ece5db96c1e97e9a0cbee70445eede00221c0777c5603894945ba643e4f), uint256(0x008750f2f8df9009487c47aceb3c8484d4822ef5a42fd2fe624b83da610c958b));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x15a18d9faa585f23dc4085798baeae6314275e6fc8db8a9ec0f9e26274fca097), uint256(0x0a7a39106e933eadf281407c0a898beed57576cf11e8023be5782828976b10e7));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1add24915344b02f648e4858f88979294ec446fcb8a7fbef34ee1ade59e2e9de), uint256(0x2c114b1834f9cb3c3c993a462cf06a5307445fd97e10d5ab83328cc73cdac9bf));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x005f1fc67bce5157064b21874b409cce8308471b84633b100f0a913f873c4a27), uint256(0x1746a9cd1398c63671fb9a547da60b00df5362d62ed5a761bad20cee7e927adb));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x142b99a37954da66ad5e1000f56b0f02a72103216125f5e472f1c2a4d47abade), uint256(0x0684c6ab7ad40779fffde543bcfb1d76d2790c74299321988d0030376e41bfe1));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x00c7d0d4fe1b810047af8f7d33ee22d038432b793981104f9aceb32a7e868d16), uint256(0x2c8889f04d9dd35ad73ab0da3bf21aa83392c785c028b145114d8ee991725057));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x20af4b7859eb0b6f9236e69612f18f0d57b17178f0aa883f7c94349bae83e301), uint256(0x07afb6ac86d302073eb6356aca169afb3ae870ccba8a54981cad1b89d20b7408));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2b66433ce22a651f48ea35af67b505b93f4c001c6a141a2e581ac823f6c9c866), uint256(0x116b11fb9a55e94f5bb617d7f648cb6058bf927ccdc570fcf6fb2293abcf28f3));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x2c1fb4083ca0665b132018cde63d9a01efb4492f12d2604159d2b7e1f97292e3), uint256(0x05c20c8b02c0a11c138b74523208bc2a9905f3024abb4e38529721aa8e9d783f));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2054d1d68c35166c79f5078ad7f5e3134df7088be3e30a5a2fd07605a8815906), uint256(0x22dc3ddc25d9d64cdc9abccf8cf798b6344074421b5a5265c90d51f1710f1cf3));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x15adba18c3f8de28c6a807d2c7c76f843329ac668aec6e06e50c65e542d5a030), uint256(0x142df90d3ec166d8c8474a142df4adf902f26c12ba792bc3238c9a6e7351f2a1));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x126657a8bb49186e55c00ef01b75d8529a1dcf1f1b05131e91f6de3b1229b607), uint256(0x0b53750e4a57b484c5b5911cbd0762f64ba412d06581ea84893085fa9faccc1a));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x0bc4cb5f7f159beb8b6831c47d81e6095a19e0f640c48eea996b501eb6fb0bb7), uint256(0x134af3d65d7b89b32b7389fa7001a35095d6d00719fe812990e35913050ce8a4));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x268458cf4d58bbd026c4c3ef8b2bf92bcd516b85aed9fee097ece8e4a25f4b65), uint256(0x06b6a83663269d2ea10b0ec839b7e17d0646f39afd3d1f4ef885bcb0cf55e90a));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x01b681a9d5b5170ca86c83417147e38ef3cbcfbb46f5033a1973f9496b42d45e), uint256(0x2c14bcbe77c18b56a3ac3cef5f6a7a3580c4272740aae754acbb5b3f215f6e5d));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0f0c53fb6375400c3578c265390dc1d54db884b06ad9b051b5b4a0409f2578f5), uint256(0x230edeb2384998e844e8b87620e72625428a8e2bcf937785d1ddc3408f6902d6));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2516ef2f7fe05f8af387994079376b3fb3d908e9810c76ac00a7e3795cbfbef0), uint256(0x179597806d73d823a789333b49ee00b3cb46ffac4e69e9f780e3bf0714d656df));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x08e85afb359dc608a7739d9c30083e9c96c4c9d55cfe70d7a68af220afc48b09), uint256(0x075558403c7a9b9e73a8e5a15e76ca909b41552ced8f96a1653c99c0b9a66ee4));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x136bf470f441ee197cabcf2b824a93ceff4f92863c4ac5497de9d685744a3a62), uint256(0x1bace209b9c37ce98936a9b6d5ff7a930896d28c84fc718951ff345e50d76db9));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x174ee573c8f52a292199b1589cf3f3b58ad3218cc56e2b1dec93ef3afbb20bbb), uint256(0x2343de444bd066d8b67db36f54712f92653e9736225ce64b561bf61ef7c16ba8));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x2fd4b2adf27dc6218ca13d93aa8fabb87f6c5077e1ffcc9c9adcbf8d58c9a65b), uint256(0x0dcb31abc00fdf73da082b430b9a1ac2e20ebe4c83661880a540d10cf46a50c2));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x142ef605488ca2dab706b41859be98ca1635f128e15d917e951755ad1f323bc2), uint256(0x275ee5c8ad302690adaec18740895766a9d34e361fb13ddfaa8f8f88a286a8fe));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x058f928a89e57dcdff517459e739026f4904bba20ef6ead3f3774a64635437ea), uint256(0x02d4daffe6ec07da540b9b406d61d23aed16aa458931b333771b93563d09c054));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x0d1ff8dd7a16e63b3330cf1734f2010a7d0d98ef525e0a4eda4b8dcd369018ab), uint256(0x18d5e45edd442bc892b43c6a1c0e389ad519f3320f79a7047f64b6fda3da598c));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x092cb0ea4e47cef48ca162f530cfb1ae1436be9c2dddc0b926ab9ae94b960b53), uint256(0x2057966abf3ee164c7e405541fd142e3ac2d043219b0723f89bef19bb83ae367));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x18634905f0a75e27edee734a9f21a9607397c1d388ba42a2cfd1d274eadaae69), uint256(0x20df1e103870ef7c2febcdf14086fb53e2e8da0d90d80f6c219cc057f5efe8cc));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x295d3ef02bf159b76f17baf9b3e7d14f8e08abd4cf193d0cc0fa7ef61707a8c1), uint256(0x15cbc3c4944c5b32f1fa952f324f50a042631cad345a28c994654df56e6d2c56));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x046c15636cfced6bfef5c0b65c12106898c21199272755e72e5ba6f5c15313bc), uint256(0x01be6f20591de15dc14c715afa0ee73a0e719a30bae9432221acd4310deb44a6));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x14a97f0dbb9d7ddb487a6c4a469949c610385c933b1970db6de91c3a251576e8), uint256(0x2cb600f975a14f4536529ad87f77749e8d268e17f226f246dcfb6e753656ca1d));
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
            Proof memory proof, uint[44] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](44);
        
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
