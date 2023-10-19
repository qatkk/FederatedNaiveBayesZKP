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
