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
        vk.alpha = Pairing.G1Point(uint256(0x113b419965fdcf38b879f8d1074a6c07750dd4717275163f7fc6fec138687bba), uint256(0x1753126c8ac38a9e150402a363d3fd615bdd4b443454e690ceedfa32ecdd5832));
        vk.beta = Pairing.G2Point([uint256(0x29b6f531b5368bf48fea514e149363f99629f5b28c311f52222d899b8098fa56), uint256(0x0f374799d4a7849e83b2ca34ba71e95f9653f62bd1513cfabb500e86b8dac1c1)], [uint256(0x000726d5fe93aed68fcf667f4d44df823a2201dad94afad2ee976ff1392305df), uint256(0x20954669a5df07c294c5c758a39afa7b6779dff77a021b25ce7fc70a89d32ab5)]);
        vk.gamma = Pairing.G2Point([uint256(0x1c42fb963f3b818457bdbf67d33a8272914e7a363500f7021ff5208f4f803455), uint256(0x213953c4e98416683043e300a794dc30b64b925c291a21ed49f76e14fa2c5e3d)], [uint256(0x0081877eeb5f3b4591040dcb733a1f7699d353ebe628fe6210ce1add4f0ee546), uint256(0x20a69e8e94b67d26cd3fa4362807e8fc10f5233f256c79f86f8c24644b166571)]);
        vk.delta = Pairing.G2Point([uint256(0x207e8c7f65bfa2b1fb2477a5aa74ae578f034048b746f28bc56b1132a328b3f4), uint256(0x0a61d08dd445b2e9b5421a93f6d8cf00d8e990b1b4c24b63f2e344873e0f6a63)], [uint256(0x25943b319c18ed02d2e3d1d1f4e5b09147be2544a77c64f301dea2ac19a6c95b), uint256(0x2c96f1c46cb5e83297695af6f6259b4fac6784cbc893e872d6b27d5070c0cf9b)]);
        vk.gamma_abc = new Pairing.G1Point[](57);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x20345b803c0e7b926bb3e248db729493185580721b09dd7b99647d3523be46e3), uint256(0x162e396068c2352c4c3f6cd59eeaceedfe40dc0babe43acd5d7128c3ddc7bed0));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1b45b4c308c3f67246682a6774aac77d634de4410250a730ca4c8eb72062711d), uint256(0x03b78393c08ae016f5f8365a91bed74865c40579f64776eef5f1460adb70d9b2));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2773d19dad0c5ceda2f9bbf97b1549e1561219ac4fc9e5f55f03e729059b1498), uint256(0x033771ce3635c66010feff95c70b29464951a2698ce412d83d4dc55cb146269e));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x1f64d048c435ff39f718469235ec9b9828f126592d819b8388d83c9df5de97da), uint256(0x0b69bd1bf80709adbe51291a32f798f9b35a66e33947ac530f0e087991bc03d9));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1c93dfcff383a9c33f6781fe4e7e6f12d903687099b2bc8281ab3ebf0f966904), uint256(0x1dc719b4c904fae8581be33f5f453b3f16e62ac062f48225e3c30649789b647a));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x279985cf7bff298442137e393c4f7fe4751e2f3ba161c3d8a31928977774bdbf), uint256(0x15b9e265af3bf854a581f3a44c2bf2e7f0dd3f397a716584511827ceec03ff5e));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x220396a2d0bd6e4283d90c41e567b79354bea981b6b30c2c397767724b711fce), uint256(0x0b5bc8983d6a2207c5efcd08a5c9d919bc31fb0d356d7032203b55c92683c2d9));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x053284a6ed7e0a07f9187d0cddcbc064664eba329e9d2d130ac5fcd32ca2776e), uint256(0x2effe83b3efe0f3e7ebbe98e4cb27ca89ace1f9b54c5ef940c65adf49624e787));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x1013858c587ea7ba65f2368cd837404e87f93a10e5753901cfa4cbbaab874d85), uint256(0x2290da55cd351dd191e62f796a76e3c620000ba47a6433527df40c125e38af29));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x097ee13e4b1381d9d89ccc33b792df67896dfc139e02ee702304c5693ed863a0), uint256(0x2a436dd87f910fde83016e20e71a53c3027522ed3d5b31f67091aa055df35b28));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0acc0787d2d61b79b90d0161e10d7d48494e33a309247345104a105226a5999b), uint256(0x1d5c7f9eab196e92bfcbe3f585f75284bcd66a6b9f8d0c8fd3e3d3081d94eb2a));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x02369480520333426d1fff13d0fc9b2fe8e8e4ad0b9b38d95318ed9aa8e3b80e), uint256(0x0996e7a7be0a50f7e0aa5d61c4c70f97da399547548913117496a62f63dba42d));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x028ae099810fbce21cdd300ad5656cacf6b742e05116d518ec0d868a9e40291f), uint256(0x0c91729909d976853e54231da96a4ef55b89363bfebbb2260354ac794ad76fcc));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x02433e743cf0dcb7d2aab6aa63519b627c21884d90313fbc54bdb5de6596e375), uint256(0x23615823097f32ff71470d224eb3848a1b040685cb00beb8c231db33a70cd35d));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x2f47483ce99f866331af9cbc54b0de2991dc555eb6c3ce4e5dea12450c6c464c), uint256(0x0d4db8338af41262698b4e91cd577c31e27af31a7a59cb831d22c54154413272));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2b2e57f879aa67f6998f681ae12d1afb9c13c495a9eda6b3965402d61ba1c058), uint256(0x00515588136092a67586391aaca99f0450565f022529f50c19f9dd69765e0c22));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2b501dfd078d8ed021d673a46443b9b9aae06dfaad890bc257f3b8f5f8126795), uint256(0x1c0e071070ce6c7776667a4274d8aeba84a72e9f0414ed027a7516b2c45779be));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1e5205cc0633ae654bffdb2ea891789a4926e07c90270138080916d43f89c649), uint256(0x214b26ec85e9af99e9d70b4384dfe740a37ade813dbc8605fb3ac77b56131cd0));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x197e4bd4b8b3138b747fb00af2002619472fcd15c669ee0c2564211671ea536e), uint256(0x296cda15813b298c6e49ce383132b2dea145a7f9c0e98e8f41a3054eaba23d60));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2fb2c4a5f2fde555ba6e04ca42399b1882907fa2d96fa2e650f0c7b9f3333407), uint256(0x1765a4bec71b2b017f493407c809d8dfd74b77d8c7d41871ed55705ccaa463a0));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1d4ea688779bc2e9532542c67a48372d54b3ecbcd4883db6d0371a4989bae856), uint256(0x0cbfe939eb2df83bdd79e5cd2b3ce50452eda0f5fb33f9dd8a6d962ae677f4be));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x10591fcbfe21545d3cf5557e2ac5ed998772ac4b47e825d39f3503a51235841c), uint256(0x2a416219a81d4c8a71bd3d24e5763a3d2feefca1e5068ffba858993525fedc1d));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x26e2893c2d9c8baa4a93a4998d38b49082e905f6edf3c871ffdf7b80184926ce), uint256(0x1f4fb29a01092562cad8a3cff94a643ef9a5adb5f0f306e11d8da38a29dcdc25));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x26279c7a8f6396cebf153f9e929444c126a1a712c51ac0939d524c9ee8cf1f01), uint256(0x009c0447b25739f4a88a069d1333f9ce3b6def9215fad63f1ff89dc88a51fc03));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x07157049cf3b27a1d0669d83ac3e87ec52c5f409d41f3136f82db7a12e184ecd), uint256(0x14f6b1730e5c55cfc8d068756c91cf6b6fa63fb2c7c89ae67f092602a9095374));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x2fee092fb5e5b22b9cb4c11f98d23a128d9426cedfb5d832cbeeb06b52ef926a), uint256(0x0e66fc5f06d09395f35e37fd0754cd21a658c4ff3d7e8eea134a815ec2e1a323));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2e9abe4735ebcaf5c6f1d0acafd38be2a9a543e160637bbdb23771e48064fd92), uint256(0x223b9c43bb416fd26bf5ee588a2f82e0ddcb75097bc7ad4b8885376a7e53265a));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1b7aea1fb1c1aba4a55a5223c77f01c86513bbecd4fe30351aecab0b358fb78c), uint256(0x1008f27c5a1402ac37b8afcf347609d1b724ea79f655f95cca5c49c426fa8094));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x207c0a11c8c1a3a1654a26ed1d38d0a8d3783267eb1ba74904ee212cfaa4aacf), uint256(0x21edf24b087bd764bce2c27995bcc8bc927e903ccbd8dacc10e86d9bd4434303));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x09832e2deb5eb4647354ffbc435a0dd538989ac96e2cbbeadff4d8f810a7c51a), uint256(0x18832981bf97b9a8f85bbb14d00cfd46119b52e53247241b9e35e62fb025efb2));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x2878b9dbf5fcc34d7cae84e2e9999266972e98d94e6de7abedd3211abf90e8fc), uint256(0x0e0f2be7a4cdd154db3d77aaae3494eb672edd8729a9c51826e268d9c69d5319));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x0c31b1e570d2d0ba98442df6a601c4e50794b6022667ef722c06b8103621954d), uint256(0x297015e4b439197d78a685acc66a1e9cb57c3e1f611545f5d9a8ea5a40599dc5));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2164ca81e34bfab378fd55cb6e322850b91250c6ce04b17ed37721e5d5f9e990), uint256(0x14a261721a51e55a12435fe8e174df3c14a534bb6e548f03b12f3b8211d25760));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x15795ade1a2a2f3bab773eae9a3603b8b85e48d93e6cd30fd355542241fa95ca), uint256(0x0284f3ed6febfbbb593d10b9e15ace96a2d68d9fb3ec5c7eff9c6c9a2068525b));
        vk.gamma_abc[34] = Pairing.G1Point(uint256(0x2091e06c95251d5b712fc991744a888a1c0b6a12104779125fb670af19a58fc4), uint256(0x027503f786b4c0ec41cedc5d86c0529bb8f3d4e18085a4436d15afcaa66653ea));
        vk.gamma_abc[35] = Pairing.G1Point(uint256(0x15a804a9b08c4c5faec7fe3b2fb6d58a33e5ec8945cce9b97dfe5f67484cef93), uint256(0x2f26086b1f2dafbb912edd2fae3f7814ec625d821ae37c21c7552ee104411c4f));
        vk.gamma_abc[36] = Pairing.G1Point(uint256(0x0f15a9962051e91040db43d3a6bec763a6a6172b1f89f98bb7767426fdcef39d), uint256(0x28bf5d6db18192b6ff2169f9560a3f61326ff877919ef82c1b1c515108d0d882));
        vk.gamma_abc[37] = Pairing.G1Point(uint256(0x11c8412c8dda15bfa3207cdb2c71efb0f4cca0b02fdba798be27e649ef86d315), uint256(0x2d5f8a1c7d4e0d63b35f5e2ecf39afe4f27b21bc4940885de4f63233ff1b6b1d));
        vk.gamma_abc[38] = Pairing.G1Point(uint256(0x180cc1601065291d987c417c4895d9830c8fb3e9afeaa5eaf4362cd9c0647ccd), uint256(0x28e8047ee4e7d824d8583f5fc29e24007e99779c42f3d92ef3e753f51ad86da8));
        vk.gamma_abc[39] = Pairing.G1Point(uint256(0x1802ec16440f9de9da6c44f51e916e8ea647ddfa24d72c11db9dac48929c607c), uint256(0x235991b0c7e1135b05cbe763c4c238ed9d2dfac39320d58dfbc0377581139dd5));
        vk.gamma_abc[40] = Pairing.G1Point(uint256(0x25e205b54c6746553d645b9984fd4c439fce9b2e2ab26c2b498d6b4368e8079a), uint256(0x1e03f921fba09e542af7c4775a0d9463ad43ab7d11055712303763654635763c));
        vk.gamma_abc[41] = Pairing.G1Point(uint256(0x2fc9a7a4971585b9e15910dad4fe29ee21a314bc4120f9f38a9e04e152c9b84d), uint256(0x20b6b471534ea04ee7e8c1156f77ca35de82a5b9d0625f44372fbe87062908b4));
        vk.gamma_abc[42] = Pairing.G1Point(uint256(0x0823f0043e80a0719cebdbd94071b59836757d1de56e2f81340c316676888958), uint256(0x2ef49e8aeb916c75ef4d9919a0a38ea1d6a8575f5354914c5b0920aa19e4912a));
        vk.gamma_abc[43] = Pairing.G1Point(uint256(0x13ae71d4522a2e324dc81c07997a58289273928768e932689994622b94e355c9), uint256(0x00f56f36fadf178fcc270e5a79b2489cb3a371eec360820eeba1ae1f4bb47976));
        vk.gamma_abc[44] = Pairing.G1Point(uint256(0x1d05a5837da0a771ee3654301ef2b7beeb344be9af57d5c30deda67f52184047), uint256(0x2a93e0dd00fff56d0b2814a432e56a2918d37a238f901b707fd78fd7134c1182));
        vk.gamma_abc[45] = Pairing.G1Point(uint256(0x03b55018c306fd3c4409e502d0367e0546f809a4b8316a7563d26cb41b9cc09d), uint256(0x0487dc38b20c28721916d84c81b255cd8e7f7504ec8fb92dbfd79cb3cd6d7bf8));
        vk.gamma_abc[46] = Pairing.G1Point(uint256(0x0d342995dbdd33b928a014735376a529aaea65d1dd0a53d4e24615b1deff6dcb), uint256(0x21bf7326bb71a7511042cbc75d82c73e1fffd4a8d66250bf9bee1cf8240d6d5a));
        vk.gamma_abc[47] = Pairing.G1Point(uint256(0x0b3f3024676cede871a5032cfbe29653b66068e3e5ae6c4acd7fb7822e1875e4), uint256(0x2b794e5602721de34742dca745df0a1b0fea6365c6995cc9f7616bf80ef779b3));
        vk.gamma_abc[48] = Pairing.G1Point(uint256(0x0d905c01705e9813e75d97c41646a336fc7e53fad2cacff9c3b89c69aebc7d7f), uint256(0x0ee0cee2476a5aee8f8338f7c2950fd423e577aa4771e4070c74b9e56168af09));
        vk.gamma_abc[49] = Pairing.G1Point(uint256(0x0ba8c9556357805c7bd5fbc5cf24a2aa4e3d858c1ee86a08adc665f1b4036b04), uint256(0x0c9f1cdc6c252cb195eca9745dec371c6f225318dab0433c6b1a284b278c586e));
        vk.gamma_abc[50] = Pairing.G1Point(uint256(0x2fb81ff046c6c2e9118e2fcec86ffbfe9391028d94af7da3a3c3fabace70fab3), uint256(0x148ed40cc7bda961d9324e0a4200c503c7db745f8ff3446289c1f94219c6a179));
        vk.gamma_abc[51] = Pairing.G1Point(uint256(0x2459482ed2a859bdefc5c14a322f4eae35a116b31e9e3af64aa81f334edf6b9c), uint256(0x03487098f1d68c824f7b0307f33a8bbd4d30636dc439d657468a55b5540c47ce));
        vk.gamma_abc[52] = Pairing.G1Point(uint256(0x03aa6df06ec48a1b6f065a838c4c62e1133b86d94e7769a901b420ae9252e8fd), uint256(0x2b1cc9ee8fa443f217ae5cae1579ff3597a4ceae8c5e67852ad141dffc9a214f));
        vk.gamma_abc[53] = Pairing.G1Point(uint256(0x1c34e36b00db3c49f0d7ede436f570d5c4c013b3d24d2fd618e43a215f7191f8), uint256(0x1f00daac177d93a5c34ca4122ed87c0e8e44fe1eb7c4a0a631ab43ca62e77974));
        vk.gamma_abc[54] = Pairing.G1Point(uint256(0x070cbfc7f432707fffb6d111e4c4e7c4d36a7b37f023b189f4a6556804475609), uint256(0x1dc1c24c74e2f21961cb33ce3d97cd28d802b41bd08e41334521ea6678e2982c));
        vk.gamma_abc[55] = Pairing.G1Point(uint256(0x0aebdf705513f6cb989bb7b1270d9e2c76669bbe2d1705c0d175aafab3818aad), uint256(0x13aa62f56d11c537533f874bb88b26907010c9f3a9a69fd5896459a4fb7260be));
        vk.gamma_abc[56] = Pairing.G1Point(uint256(0x1ec2f70315abbc67d9f20f1045e2f15fd1cc1f57b72cb6fc7d153b03fc16fddf), uint256(0x1062709f3552c279818c96867ec91eb6e0e17783427398530a79efaf56d95bd9));
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
            Proof memory proof, uint[56] memory input
        ) public view returns (bool r) {
        uint[] memory inputValues = new uint[](56);
        
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
