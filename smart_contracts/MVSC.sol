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
        vk.alpha = Pairing.G1Point(uint256(0x16e2b58bdc9d902af018e9b1f18cafd09b0f7c68325f0f187504116e04fc2644), uint256(0x0077c03fe1b753db2dc8a533c4ce670aacc144aca80db3c496a6a864768250d1));
        vk.beta = Pairing.G2Point([uint256(0x2a8999d6bd098da5075d72c22d768dc96db53b7760271427f902f2d4d2e8979c), uint256(0x0c81f1973b364bffb783d13e988467a5cbe7d52e95ff58cfd17d07c6b13eefbb)], [uint256(0x25d5ba9cb08d3e47e6eebd2eaa44a265e95b508bab404598734565a8ea9b21d3), uint256(0x2f6ef9c9022417e25718c2ddce9fd920a876b2e7f99a1ccb4a352a0c90edef4e)]);
        vk.gamma = Pairing.G2Point([uint256(0x18af70163844db8304c1a92edbd7d7f2c1ba236f498bc72558531fb590bb738e), uint256(0x1b34ffc018a8670dd3c6e8cd4b9b9f2d0be6aa67f78c2f32a41c5ed04b0cba9f)], [uint256(0x277282e87c1f1879e00e4c235cc4e99b2cd632012f01b4897a3f1c06c7f22053), uint256(0x16ef8bfd377e4be69442bec63fc4cb7c66aaba51c479463177967ea7ff8887ac)]);
        vk.delta = Pairing.G2Point([uint256(0x2f0ad176c33e224117b7095db4f5d4bd6395dce558f19db93e0130725710dc16), uint256(0x2c29c1aaacf255fb86ed8f43fd9edf889f35c35a8b4010b2dc490d1e9dd954d0)], [uint256(0x067a67c2b701ef4ed287bc7a5bd6cf7390aeab882fe95dc46de20e9baa70a8e7), uint256(0x13417fceb748808f2de73608194351e35dd25ac2964f47aff406d95a622aa061)]);
        vk.gamma_abc = new Pairing.G1Point[](65);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x043b7cdc252e80c0ecde05d5384c00f63009880c04601ddec9e31a81a40b86bf), uint256(0x2a86953d28c7eb0f15ff09ed2b688af4a6a76caf18e6d4d3fb7b9647056e096a));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x095933b15fd3dc380f529c19a39559234d2b78d6ff87b3f19438896adca61f53), uint256(0x133f2ad6eead9c44cf54ad1a293dbdb957eee5d1bb303b19da932cad3165496f));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x039d166e600cedc4a84391a3de10d27389e5ea36908500afe226d8e3aacf9e56), uint256(0x065939edf5bdbc02879231456f305309b3f15d3f548c6e439a50df2dddb8b183));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x0970929be5a8cf81f536f832c1a9ea83177272f0d0419281a9ff37f5bbe098c4), uint256(0x23f3377b276517dd5ee524b5c9b86d35f28dd502c85b3ff4fbef4e9e6bb5a80e));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x247dfcefe1dd1fac098e8df3faeb9e016918c34943bf56cba91cddcc9f0ec740), uint256(0x303a4330d9a63dcbd5290f09b41f85674d58aea52163c1e2732568f890faddb2));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1e67c5a1d36805dbbb884311ebc80af195426b2c48ef742852f373d3846a4e80), uint256(0x0b19ea56ad429ba8745af7b409bac1b17eb348b2deca36be7520575d7a03a943));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x1be10e4cbf0d0efab9693dda576a676b4940b9588ed6d48732eb13b3c9a8958b), uint256(0x270e4535785cff5d49fcdd39f6af565200fe6bc964c58433ac49623013fb5edb));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x113cddb42a74cc63113c3b1ea2167772eedeb61d3f41775c764d4818d9b3dec4), uint256(0x2c91b1000b712ae1c5521fe7118a726ea6540db2b9b9006b4850431e6617efa0));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x00f1058316391989e9fd25dce15cd96e6b0f1eb442cf3662be9f1e4ba4133b33), uint256(0x209954eb62ee3be82da20d02b829f3a6f7202d693380817bd37f60a3e6a1c398));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1029ea5c64e69174352f5d48f3624cf344a1f68d2b21b4ece8b48ae8bbb39911), uint256(0x1c6cb394af614b0473d60864ad1a967026ed89136c0d6d0c5089813262d8e90b));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x148190fb948b6daf2c35b5ca62d5d2c217158b1a2bbe7be049da3573ea8817a0), uint256(0x0500df5b36fcb927b65a2be400a39129ff5eee2d1d1a74dbf27b24dc8be5146e));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x0457f10ce553ad2b48949e533ff5a559c627339d6dc200438d4ac0a71cb19cdb), uint256(0x24bd1423ea53bcad43dd28876d3dff31526f7943f452d3a3a4d384bff19f2e25));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0a694f76c60dfb57d627a808a2540624027c24b115cb60b804275ca16d779a9f), uint256(0x2351a1b58354acd88951b78f764fbcefc29c6d269a1af177bcde5ddd52a3bb87));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x2d352c972359ac8f3c8e9fac2c6a59945fd42a11f500afcd3c14c81a2968614f), uint256(0x0811ca88029217e0112d1e56469c34d53f13a6ccd88ef1d4089625f4caacb145));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x26898e8053008096a8570ae36b4b14617682a43bd670b112ceef96c46d55d5cd), uint256(0x0372e7ca202086762ea868a2c34749af772ed45e95fed0ba0124ca887f0c7217));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x262939d1092f07c76343cd64da7754893592307e002fcf9611747f434ef23ca3), uint256(0x159ccfee7f34aae843af5879d3f5c0fd3a03c57bd3d8f3cbaf533146660fcb42));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x02c43dff006f6d7cd5a631cbf992afbf87c87cf3a48fe977e1d0db28ae11c957), uint256(0x06c6683a8c1cf9a9bb622ec2c376e8ad72d970b62ab605e034b26e0a24e8ded2));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x18c8862dcba153619f45b560425f9646e9fdd123c06fb0b409a996b5f6eba4d9), uint256(0x19e62b6c0bdcbb5ff457340de21994a68ec30cd9b7dfe0eddfedfcd0e9596c3f));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x15e468536e142a57e82d4a76ce122cc4446f03aca09650ddb7645c77e563f59e), uint256(0x1d4e4d464bed8d28a50013d90e31b2e0b7f6736ead1dd0d46e1bb91a9c09a36d));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x07221216c9d7d1a78f4b8f2236c241fee7fb84a20a991da4584afa56be1e55a8), uint256(0x0ab76a06dfe301de35b6a3b840f8963e71a8950c2644fa4baf12cee611eeaccb));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x076269f841e65fbc37726b57c18505c6edb7c65ae1bdd8927f93e01dd27c8dcc), uint256(0x09957415ca1f6db8e9331869cf5a8a35c7d907a20ac7f537cc2e7b5eb99e6310));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x27421bc6807e8b557bcc52a3b6057f4eb8efdce5438625ff215a83c511356c02), uint256(0x1c20d5b2fc8a8f0ced2b548e1106a23b0a8e3b57bdf01766a6ea23709907c9f1));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x3046ef8e8bd76e156765cfb2eee46968cf37fca33f4d3e3ffc5bbaa715aace5e), uint256(0x23221944660b4a587bc048cd328187173addaae81d6607740e058312c3d49973));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x1d502aa1b88b1ee57b22a83fd1c4f94c6fa55523740c685e7d9e737acc905267), uint256(0x2a7ff309a870ce491703cbe28b5fa62ab78624122c74f43f713af928825c8ec0));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x00e8c0386606010fa2176682950e6d341816b0983f24d7dcf8f64810f047c8b9), uint256(0x26fcf4277bb5ccf772c958a5fda0afa85f0000f71d06432d09eefde0925741ea));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x18c65d4010a0d7d5c742bd4555c6b83fa6b937c28ba60c5787b1ab016a471223), uint256(0x1229d4ef292ec56773c3707499f9b58e9fb0cbd73843ca03ec982eacdcfcdd49));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x20a0b40ddf2508b34a425533167e9d49666712e9c53a2803b2d4b5a1c48edb58), uint256(0x138249766b635c8677b6d90ae34267b3c2beab1ab459f8832a30ab0588a4a842));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x126d1c10c8da273be72db64f9964ec62265662447a9a1c7a614f6b54e8967ba9), uint256(0x1499e606a027cd543a0d9c3f4457e7550a91b62a0f2aa5db68d6de50a8489860));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x0c341c67e1c124db7bf3b14f359e7d1a198920f3436074a5ff556dcf24812a7d), uint256(0x280e012a44fc05476489006cdb0f5b7e00dc629e27c8e91890f68f2ddeb833e2));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x17d0d31d4e705156112b6d2954af9eae74b10f0bb4f48d9ebcc9d7ed1b415967), uint256(0x2a177c0b0ed3b87b8714e17eed8e12f0906af07bc695d05fddb5becc81ca53d5));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x053dba135896906c86a529fdda6b64de5a33310a54f048f4b8dd9bf6e6496e10), uint256(0x289952b6173326aa962f8bf93d61036a05237793c17a375c27e2cd21f9d3bde1));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x1ae7b2f3b0b795480826479ff72a38cdfa83f080e469f4c5f5a274d2442e6f6b), uint256(0x0b2424e314c3cda21f5d8a09e7c4a99cb1bd21c9557d04d2e8b5f0b6108dc0eb));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x06ab3f58dd5cb1928a89b2713145c8ccab8d4f0beada1caa4b978b8746136113), uint256(0x0ef5fb1bcca2e70cf1997e13055408eea7073238e154a8c72292c5edc7d886e9));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x0326fda1f872af3874b754273ad6019a530b0c79ea878277e8281e9bae6aa53e), uint256(0x2878907f47967c2d545e3b7d43fd119ff1bc458085bc3a64f7908bd34afbbbd0));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x0c320f3ef115f0e6f2b9a319e0df877cd8f71f8439d500ed28380981ce0dd1fc), uint256(0x09f0d32f32fb7d27d973e6859bdf17d051096cb73b6f4af72725525dab051de5));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x0769eb8c863172994ed95be05fd23168e9970bf5241c0dbf3bc2b3e1cf154a3e), uint256(0x2113481567d1346742fbb91599f4a76a56ba6756a8a8e58161e952a40daa0f01));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x1ba47c3a104a1dd6c5cce2f11bf22de17e92c4a16fa4f6177358f1938f85a3d0), uint256(0x2dcb3f203bcfd2ba45cd1b2f2f1c817bcd76a1570922aea395ad95f123cbe55e));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x0ba5be647af88be915209b0738f4265ed476fb2bfdeba7f119fc78cecfab32f6), uint256(0x00e09e2202adb8c87b7418f423979f4750d196d223f3db6acd110b19956f4959));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x30085376b412b42f0cc3fb82f7cac30a1d0cfc4ebad77b9cb2e82b01026c1821), uint256(0x0cc5a5d0778580a1425193443addee042bfbd43eb02122b56dba5d19a38fc037));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x22ce97e54cf84656d791d19c8eca4ef2541ade5cf946cd1284b82aa1ec9bdee6), uint256(0x1a78c668d268b168c58e6a4fd6234148346aa7e4b9476584243baa17caa28d1e));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x210ae692f61effb02d774e8de1a90aa87d410976762598d2f058a099fe1111a9), uint256(0x1d7be861e4e7cc48d2ca985bd2e30e75434024d1e0a5f40ddcd9af3da6d00090));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x22fdc527562e2f982aa70f117bd25bed441e8f669acbc0a7b35c0d0b16f3ab5d), uint256(0x1f399278cc9d759e34b4ce896ff8a565823d81b9e7bb0407e346d4eaecae0bee));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0126e2981405b516548fd319fa1c5d4334a56f7e6a459c2fbb17fc056e092e47), uint256(0x1d23769d249f13407662953a6395b357ee049e94d824c5c2dd4f6936331baa1f));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x1816878e0fce4f071d85a88783bb05dd7dc14ac47ed5ec2b54f02e4c7a17825e), uint256(0x0b05143367ff307efb26a691c44aa19ccbb147d6c059b7102f7088830ce17a4b));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x0017f26b64397ecdd375b630d72956c1aed1ee5ba94e72e71eb46f011da55bee), uint256(0x15f1eac09c41331b46317bd22fcbe5fde9a3f559423f358e8402c27ab1609c99));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x29d0efed07bd6e6f602c252a31450310ea4fd9ba60d900c62733af7e976b2649), uint256(0x027352385931b0520215d0ab243306b9534679a45136ff22f1b6b63943795f0b));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x29ebc167f07fb606e393d3efe719f266daa3df4d154e9fc5844d48ff11bfcf51), uint256(0x2e9e092a1c91daadb1e8f1085ab72825773c7ace63e8883d11aa9680a3d5979d));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x04fe2ecc5e516880e776fd98bc7a16ae6eb3c4a554b2c969ca6edcf38a578ed2), uint256(0x2b3c793df70e3e1fd7c700e9e2928e413ea421a5cbe32e1fe0d8719d988c2208));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x215bae442f3b2281f2a62bc7ea1038cbe2904d0d39fe7d694841c31cc77c96e6), uint256(0x20f09aa57c43314c666f456973a4412a5b46e5578e5d7c17e6abb1ed08e90b44));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x1161f0568a3637a35560703f4284f3b6a1a3ddf3c3d4a702b4f132e51aa77dec), uint256(0x13693458762185f36f66d8dd9728a9554c976af3a9d4f86513efb9e24fdf42a4));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x13a71d78e999a51d06b6281e2eecac978a0372395cd03e3dd1b1bc39f63c7c4c), uint256(0x2428e89880da4a35bc35698f40b49fa74caf48d6e7d1a6d24042b5c2c9b4ea52));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x255fff19ca2a8c49efcc25e81655769d77b10a0facba2d321433b5dbf280dade), uint256(0x2d58d068fca93fa2b1f35b948fec00645e918a70db3c8b58a98543bb5166d300));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x1318be6496012e7bc48a08a25e9462a3c074587611dfbf2d034a624f8806c89a), uint256(0x1644b041a36f4263e371c66a361c5f723ac6815f874fcd95e1b7069071538684));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x07d03e9fcfa4000199f610e353ede76a3705d906b248fe000d04312682f6fc20), uint256(0x037d8ef1ec88a253c60d7f6a797d16bfb3a6aa89043153cd91ecc84a1b385679));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x07dd8e7da31d82727d351484992c8e6ffd12f44a15ce3b95be9910db6a53c13e), uint256(0x1432a53b942ecccdb81b8b75e4e96d5bcce3a1844d49e6650c251e1986b83b16));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x1f0aa6a0c8864cc97aa5f45a445384d4bb90ab43b79a741dd1256ccdcaedaae1), uint256(0x1443dd0a1de4581483744b59118319d97487147566f765f4feea21b73a2d6344));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x1efea116a23a68bfe499c3aa128c9e3e247326de444267f929faffa8deb2db5c), uint256(0x015b527c48b7d743eb8e1a7b14ed62dd1003e7e08be2ba2c7702514c9d541570));
        vk.gamma_abc[57] = Pairing.G1Point(uint256(0x1d945be6062d61023d0ae2213e1d89873e7dca894095dee799feb055746dfb32), uint256(0x2bd58c94a37474e88c769039bbab37490332b09671a3cdf7fd946b3913ed8cf1));
        vk.gamma_abc[58] = Pairing.G1Point(uint256(0x13230bc4955dc1af61cdc2eeaab914f07754cc894c25ce49f71be64e3e503b99), uint256(0x2a561261ca2132828f76593c64924268fe57707d5a45fd943c44ec38c843e314));
        vk.gamma_abc[59] = Pairing.G1Point(uint256(0x29e1cc9fcb03bcb4900d3cba8db32b3a83a917385b1da1fb0adc900496cb1b89), uint256(0x0cf959bf64aa9d0dc0d7fb6a17fbf94b674b327481b4a8d1df056ce9e4772d67));
        vk.gamma_abc[60] = Pairing.G1Point(uint256(0x23943e0582a575425f6e3bb4cde72fbcf7c2f4794c9ae00656ee059fb6ef5f85), uint256(0x0c105d0031272a74609cb6c757bf9470cc2edd126a1c061836501cf8c7b928e1));
        vk.gamma_abc[61] = Pairing.G1Point(uint256(0x174b2e7212ab521bdb98b72af9c7b3c4c066c056f2d7c9bce07e1edcb6ce995d), uint256(0x2087c2a69b7990f703d394bc69886f9791b90bc19d4d956790ff341a95b6d1ee));
        vk.gamma_abc[62] = Pairing.G1Point(uint256(0x07fbe253f19cfe4318431829c7eb20ec0a48d8f5556de76100696d76eb5017df), uint256(0x144e8c5118c9fe50ba69238ec3433576082cf0f6d163b5d9d5f15e693327be1e));
        vk.gamma_abc[63] = Pairing.G1Point(uint256(0x211846d3b4b7a2282e1502d259b525fe12c5070bd127e727a85a70091c82a06a), uint256(0x0cc8ed85b09b602b4311368a0a792cd701e2e56141fa7452114ba81228ad38e1));
        vk.gamma_abc[64] = Pairing.G1Point(uint256(0x1129e148e12f9ed17287ed921209c3f7d883a6c6e80a1367334d1472e41b20f9), uint256(0x0c80bcf3df8a19b9badcc2c27408e911e88239f567b56e7a4f84831a46797a35));
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
            Proof memory proof, uint[64] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](64);
        
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
