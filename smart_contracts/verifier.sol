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
        vk.alpha = Pairing.G1Point(uint256(0x0824bce3934b76649ebe53ade1f3968b8f59aa4e37c14563723e3aedfb4af752), uint256(0x0d463ea430471b03cde281fd1ca04a64f2d3a0cc6880befe97df79620aef1a70));
        vk.beta = Pairing.G2Point([uint256(0x08b9a2d05f3e2e88e8c1fd805c7b700fb4261671c1e68ed127b96868763c91bd), uint256(0x28704de4afe3a42d95b3054b45c6e4b076b4a26de23587a814ad00d87b70818f)], [uint256(0x03576a74fc4bb76a2c2abbfd6a0e2d55eae93579d061b8a1ff22ae8c6b9db0ac), uint256(0x2e91b2c70ccd3cf0646604c3939f7227150e98805400d196dc8ea0b6ad6e8237)]);
        vk.gamma = Pairing.G2Point([uint256(0x248b12eb451c6226c97f623ba661288a456725785143b1541b66151046db1dc7), uint256(0x2593267366362db96172c65a9f05777edcf3eb798f6aab88cec5bce182d98082)], [uint256(0x1eb405931a851ec7d3d4f10cc8a3b33db30062dc5a15c9eb69ce2e9cbf39b7bd), uint256(0x0050d388423e5e06241d73f4b2883826c79562ce6f2ca852e89e690d83645a9b)]);
        vk.delta = Pairing.G2Point([uint256(0x1c4e3b8dee2e325cdf2db64a980f7cdcf238b8375d59e0c10c4a9d1b775bec50), uint256(0x0d9acbde8dc106849522474ebb575d7219c06026cd99d6a91eca75a0fbc9352c)], [uint256(0x1500d60079425a3bf18017ef4179fff4db5a27dafad5436bc0ad8e625fec1433), uint256(0x0c0db1e4b56f610dfab7a986b0c09e628a12c70dd4d5155de06a8f1b7b325e22)]);
        vk.gamma_abc = new Pairing.G1Point[](64);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x273736d630a47292cf0646d917d916263e837a57599a57c6c64d60db6ec047fd), uint256(0x06e0ac79018baa064e36ac691f09eedb769364c3320d1cba6f01cff4b3e4abf2));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2156aef4d57c94ed91684ab7666777125bc289988bb2b37376935fb68defdfdb), uint256(0x0a2ac8ba587ba7ffa3e07892f2ef871669997d0247a7e5851ebcfb9c44b779bf));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0043f76634cf7dc3917414b592128c80a289d2ac8d104cf459aa3842029fae74), uint256(0x03a6d6cbf5e4a714a8aca9fe290cfc28c38ce52472803f18e403e7019e27af30));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x047b590a52a7a043cc9fd331390561d254a89548b44253cdbe0d4197845ef1ba), uint256(0x20a554b9f15d5fbb0f6a12ddfdca4767d63c1909d278827380f660b7307bc76a));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1aab4c1e02035b84f2d256d43d9e21fc3c5f0f138bf8e9dc262dd1254e1c6d0f), uint256(0x0c42bd4cf2f33bb0e4902d60104ea6ab980c77e2a64cc1a64e0cdeeb1a9888ac));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x05795535c53541365d97735bbb018e6cba18e2e6465c648c2b0ea452ae4e3d29), uint256(0x07bb139de9fba4187cc48f3baa48f5a392e1a81f85d313985dfa9eab4c7172ff));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x11d554e8ef4320d3202a0f2984c19a26b107ff8ea931ee4a61f8484f9a37b393), uint256(0x12b92e8d65ae706ea8ace641072d82125a92c973262a2d993eccad4d57070f6f));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x29b67d39029703cc33ec028f84790d3c5d27934a4ba1f8bbea046e070e974e93), uint256(0x276abd927f0ee99235890f7df805e7bef4d91042d11bfb9f1e503794074130e2));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x05bdc64517f9b074ea589dc0e5dc8a786d5cba269059b6ec948eb55f1789c654), uint256(0x196d97ed4d50cfaf6f0227b1170e6d9e578d1571b53e5b7e0607d1f2f4046a28));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0cfaea9fdc07ffec0a5383fb7c5ac709178ef87b5ec9070d4c614a4c13cb0ff2), uint256(0x2db93efa2fa2a3d5ea82ef321ed5d2c18bb7c8922a9823d3814a40ed4bf85d03));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x134e59c19ff5c7aca2a2ecb536f48bf5b94a284d284cad187f7de61379fb0e7a), uint256(0x1b13b43510849f1e66328d1c9c4e18eabf1cf7a2205116add66882e842cba55a));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x05bd880590cc3001443b8238e16832c3df4c2b18dde0f1eabc00e2971021f786), uint256(0x18893907d6fc37b714b4179fb5dba107b5784e0a363b949922a10323974d5d57));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x108ff1d9b7ab6f9312ea0122aaee02859e88b93e74215b5d54eaf378b9df0489), uint256(0x1523c9904d70987054ddbdcde611c0db13fbe4f76b779ed8d8cb4bd266c8e791));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2f429bd94d56a658c3953609b0d6a37b28a045ceb910b07961e2821909bae256), uint256(0x2064dc025eb8cfde742b3e544a8a340f838795a1ad6d696fba7744ed9d9ebb08));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2828d8ba5a4739cee6f3a0f5d5504ab2ad04568432414c96bc6591c095c14245), uint256(0x2d1ec70b05a8abfd2031f8efadbad97d5e38c77dc44f5752cdcd68fce42b8287));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x14eb50298232dc2715a05e2a21dc2b57da7417b50ab774a413fe1a529dd34439), uint256(0x0e9d5e1b5c3201ecb9510d1ba5e5b40d74c43f8071ef4b4607d0d64465919ddd));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x283cd010f2a8af15d9580971ea47d42f42033e8bc84793cbf7aaa56503ec657c), uint256(0x18a8ad9d132d88ce64d2fc5182c4af4e99b62b44d82b2ffde01ba56a2ef4ce6c));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x250746c1bd318c265517e1db724882e6fdf0647790dd3d42c60d4aa542fab025), uint256(0x03640cc1487df4bc0e8271a033a3c91f26c8bc2bcfaa0214e850c5b109684932));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x200737d7d7b8ae3f26cedc4cabf439af6ae7777bda1323041ad8664c0b3c15b0), uint256(0x137bb5a21ca070753b576de669bfe5b9bbe4c68f3e8e18b70f3bce6f81e679e5));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0f8179384001c34c8bf91a3127b1c5abac9569d72e4dd5274929b8ddff922b73), uint256(0x2a0e501e761f9b9308b4366e45015b681eb5a9937dc4a5caba1f0106c08c688f));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1b39c7250a774ea16c0932f83fc5ddf6be9c6057c30e124b161953bae341d3d3), uint256(0x27adc92320f4f4c3555445d0432b70eac95f372b0b640ed75a33ed63b2a08670));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x1f5487df3b873eb6f9861c703577422977ceb16603bc3eab855e9149caeedcb3), uint256(0x2f4628a3a2296df84c3d90043dec456536e6e6bd510650df775d7f7af771e8be));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0ef3ab10a066b11113226a34e281ba11fb3df36e0c0932e4893459918acc0867), uint256(0x2076856e3e8631f7ab41418d2c921f443a59a987463282193b2ef0cf9fc06db2));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x2a9f963e1be3d0b38cc3f6ffe5636f00dc41cf6cd9ca864fba1cc1aca223b071), uint256(0x0f827a70a6243adaad4a5fe2f22115baa9e135c370aea0be7cdc699b3771d0d6));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0b387be2f5dc491c20b4dcaa29756864e064d056abe2fa469a86ea9845dd9a19), uint256(0x1657f763592291609da3e55413af9115329a2b0d12b2ed3a7c40382dd4431f87));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x1937364d6778a5279e0f031cd8529469783c4b4de63be2a5844a72b6c180852e), uint256(0x031de7ee02aaf0b6bb9d2a81c1df2c25e1330e4237a15d71add64cc5c241dbc5));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2ea84cee4e9696c45f60158b3b114ebd9ff3c319e9f51118be1bd98a42d99b60), uint256(0x30349aaab5caa4abc8ff3515fd0670f67a9302b0112a7cc03df895587b74942d));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2ffac823568392dde313b7a2883e2e6ac1148a078639e3603e9eded2c43a3b23), uint256(0x27db8a3911bc62a947b78b1d15dd11d6cfd274a0056cbb7a96fdb3f562125d09));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x19d81816e3a49b051f9aefbef18c0a790aad2233fda29c7f938cd00d62ee8634), uint256(0x17e7cf61cbc90bb4beb5de42b95a1ae89a550c4841413e7769c9bed7ef8745fa));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x10b272c70ebe69996b174ba1b20273264df92c1ca5c9076736d11620fac4633f), uint256(0x2ee97a8acf2e369505ab8c41ad058af564af0fe56b1caedec38cb2142fae4f4e));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x210e1dbc6404cd161d1fb837fc9de44b6a30b235ea6f2817c8b6bcb72564b97e), uint256(0x07953a71869bf7a47a5ab6f0fecefb70141ed10b3c077f1888f47e2ddedcb997));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x14e1cb8cc197bebda8d02695f72a4c15ee335f62536f8c9e8405615902f504b2), uint256(0x300343b76cbea87a62b5029ae548e729b7cb269c51623dfc570231ebe16a654f));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x228c6d6a39a8925e815fea6278fa7fbcfd5935870ed7f7f7c273a85508915c97), uint256(0x0846acd0f87b88bb87ec03b3446f53342c587a870ccd2118b9993f92905ca56d));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x18e219f55d31b3b2bcaf7445b83dbaf061ed53a6998dc0201b10c2b51db3fc9d), uint256(0x2d102a46cf3630b6bdf673c6e56244b7593137d09d068df445f078778de49121));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x1c7260bd4f4d0eb48e2e21925b89f6b7c26e1871a8d32170fe9ea3abcf1d8bda), uint256(0x1abfc211d4e05a6f4fca9a88bff5a5dedc911f2e925b70d0deac1e6f8e8c857e));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x094fd8e9998a71448a4bb16934dcbd2943d18831263c6184d1c9afd0d482a29a), uint256(0x0767d4768a90388d62931968b64c9b321feb71c4a7c594094bde4c21697b8508));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1cf4d4991e7558203b64823d61ff8ff4eadea3ff2bc00f2d929ac03f3917cdce), uint256(0x02098063a3acb83403defe6475f095c1db2741443dd1cc48dbd871eb9bffe329));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x115659d41ad2f7732ac24703cdc658bc8caa79e56d1d2a73fa5b5a1394ec89b1), uint256(0x2596387aba304966a7fbdd8dae9dbfd0ca53d1a49a72f266220c068144285503));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x0a67f694c0938483e7695be6175eefa062beacd58b9a271d640b05d8ef89e27c), uint256(0x20ff95b103f2594dfaa63cbf73c0d4d120d4fcf92d4fce263750deb10658c9a0));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x16b675a6d3027e9c323cd9d4046c2c78ec019032f39537c9188b93dc945257c3), uint256(0x23c7f9049389295c178075f1b12f2527e08e887fd9fc2bc14bdb972498b28d80));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x2b8f39a650f647c5a5af8a52a8a5d9b90c23ea4b74c958d2caa6619dc78e56ea), uint256(0x2309066bb968062942011a9d6c93fd01ef8077a10ab928a90783722e0a854c31));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x1cf38a7bd8ee94f31230a6fabe5b9d68105a37d80c7cb05deceb851d41b11eef), uint256(0x17735ba0d636148e3a339926c14a53c766f35fa003013fd4d0651ac8d57ac9de));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x223264a625f19010719f2f29ff8f96d123ceec2d4dd455bd47e934cd64a58eec), uint256(0x08c515f59705830691aaef72a477d767c244438f2e8ca09e67693faba2835868));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x295fe17fb04adbe268e5c413cca67002449cc7be30343d75aff4b50e7689aa38), uint256(0x2bb743a3a406c06b8ad2f4f8c4ac68980ab9fe7a82806179d2646ae23b5ce905));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x19d5109340850287a03ab276d46be8afbbc0f48c8af8289ed5414522fe7ecc8d), uint256(0x0a552b1ed8196ed62c1dc21912f6fd2f7a48a951df9e2ab1807c398cc0b779df));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x07827dcafbc6fa23028a47bbf5e1080b9c47ecd3bc1e150ebdbf87ef8cbcfb56), uint256(0x1c9f552916a5c598852b1031b6f3c0fa222a383575dde9707304d0a3caa89962));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x2508d0e2924d18f5b9335959f1944b4bf50bb54395770e585b4419f94f411e97), uint256(0x13ef7e859d4faa23f36fae6acb5d5cb50e428b1f284d393cb3cf6e0469ba85e6));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x2c79147fc8974d16c51c2bdaf2afa55ccc6af8e352aaed0a1d7f989d1d0c58d4), uint256(0x034633153642c6ee6e953e37565dc7c27c7882b31db4fbfa5913623613838b17));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x281c4ca799036acf4056702760733461639960a3ad21d089d0763b863e7d809b), uint256(0x1b45f737e8aeaae99ff308fc3e95059415f489f28cfe1494a2a8651ada8b8ba7));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x291ed2458eb4c471244799509702a30f8d76694aed2b4b6a3b2af9be3dae666d), uint256(0x1cf306232407f4a49fbfff174d2c41be66e1e5adfbf5cffd9812f6fb09356d93));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x0d332825e93c33f556ba8025371a87ec40b775e98b101bc2dafee999fc7e25e8), uint256(0x0c8deac742186d811acefe954531bbbea866c45534dbc3edff5cc472a6de3f6d));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2d454001d5406f2d049432d7f560c913d34abec8cb1d6839f8102e8cecbb69b0), uint256(0x0fe1f67e4fea38cb77b0f77e690c89c72300e8d69cf14122dbd3fb962d9fd735));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x140cbd9c70734778607003ff6ff69c752ea68cdf194c57128202860ae5086b2e), uint256(0x07fc30ba7f13951c772221a294dca49747f7c42855f3a413b109897c54698f66));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x1c01b1ef943ed457815b73dddc033f50e5bc433443d161b03d2c68d167071cd6), uint256(0x28b388ca155731d6aab862a1eb198921c8591e4d5bbdb5a15e0016885faddb82));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x193d0cde3d3de690804bab87f0009365ed69646d4b184aae0c83918897f36cc8), uint256(0x15222844807f05df21dfba569e5e51a4a934c47511d728613aebc6d3d263a35e));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x1969daf601a4f8db0348131ebaee94d3116c602130532bab777ed7a8507d4509), uint256(0x03b80701355c5c89758c641c24856b4f6056cd2d9fc267eb7e7722d5cc3273f0));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x2b7fa8b4547e4ba0d38fce677f8002268f0720e55a3c2bd272564b51c1f5cbb7), uint256(0x2cbc55212dac1fa834e1752e3abced7d17068c44fcedf1e861bcfe64490b8cde));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x125b346a71d8f6f4b66e861bbfcf9ff5996e1bd40c1ab821ff83fdca451d05ce), uint256(0x0ac760745fc11136fd2926d449453d28928207c42d6957b9852f1b0e204ab756));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x0c04e635a72119495bf7d06a846769c22839e75817821327538002907d7c9b4c), uint256(0x1406d67e7a21b33a774976e541858da884184490ce45321ff8e309c764276d1a));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x1c732c7aa9946e6dc04a999cf06c72a6ad4f9bf8a162b6ba34a39c93e1ed4426), uint256(0x02929d9acd3e145c7f10e54568d7a764c43da4eeb14676af3a77f33181a817c7));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x1299107068b7a4aaa68810b3a7b371db23418a15f357d22eecef5dd8c7dc872c), uint256(0x06c2c6f1a4944130ef84afcdf858e1afb8955a4817688d3718f4795b525e7643));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x2d3643959d1912d97407653f638c21fba967ff165176ae7651cff151dc7b6a17), uint256(0x054ad651e0c75a73ca96f7d55ec7a7717837b9f8d301c6de0013a29c5488bf6d));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x21c5ac7e8b6c166229e2faaa93905cdd3e3f093e94a31dfd7a6fb75a4ec6930e), uint256(0x188877d303c28a7b88717f825171049cc5c6d9ecb8bc4feb00cca5d130a22b3b));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x197d9c2c9e0ce03f137f0e0f63083fc0d275d5a7dd7825c9004fecb77bcb6c4b), uint256(0x03c2b1bf0b3783ebf7e21f62a3e8721af806b0badcc4fafa2223493b71bca4e1));
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
            Proof memory proof, uint[63] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](63);
        
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
