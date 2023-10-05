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
        vk.alpha = Pairing.G1Point(uint256(0x10736efc7e05063484dd092b027d9cbe72311a795d7c2f687df1bc3b88ec8e72), uint256(0x2c3b1817b64685e86635eb037e342a5759c514b6158cacb7566f455afcc9d2bc));
        vk.beta = Pairing.G2Point([uint256(0x057e98cd3abe4fffef2361a901aece7d63c070807e4ebae0a2f2e5eaf748bf07), uint256(0x17017029831b7df7219c31537086dc02c41082ca3b9a047e1a9b7ac156fbaf89)], [uint256(0x30044cc32ae3927fa39737c64583cf99fc470f91fec7e3748911ed2313fd1bee), uint256(0x039965446406c73bc59b0aad96031a11b29be108af531f60c15431220e889bab)]);
        vk.gamma = Pairing.G2Point([uint256(0x06e7585bf4048cc4519d91bf409fcc22f6a7e2260c2f283969a3f9f8b383d486), uint256(0x09e473ae7f1a19553e86d5d173f00cd5f6f7f9870d97fbc17cc92f8f0a53d2ee)], [uint256(0x11818c6ab0d8febd3f57bf6942b0acf399238cb97b53499476a20a152c650fa3), uint256(0x022db334112936cfa0cae3797a71e0d1cb40d09f201e1f34b27bcc0b57719408)]);
        vk.delta = Pairing.G2Point([uint256(0x0f6c650e1b6ac43e7e2d326a28d3a23e3a956202c542a2bdbfc0d6b1bad902bc), uint256(0x294ff668d23fde9d767e45df9b3f1be130d92288bb00a5916dacac9d5a84c33b)], [uint256(0x231ce3a82ba9790386d091074df7b7057c97e6378a49ea36b9f7e0955b887126), uint256(0x0b74bedd71fba0b2429ce78808a53f9774bc905f9550d0bfed6d2f37a47d0b35)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2b5c17da56417359ffb965e55da5939e47cbc9391a684c975d0ba20c1154f06c), uint256(0x2261f7f85580848ca0bb571557d4f93990249d34743b40c8a36a7a3ec9c81a33));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x05760adc14a469e9c794e549a8f91256c18646c3fa8ed002e5bd64390c7fd91d), uint256(0x14b8676b6a812cf471451b12c79b30ac0ead91de60fbd6388035082dba77b734));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1cbe4b4c1b05817a7827c0311fb66d8f192f2b186237b168ef0e79cfd7fc5c7b), uint256(0x2346ae7ae41daa60f324e5a4bdd6aac31cc5e96d6060a2784e30042c751893aa));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x11ec1d7dad92c7a2d2434f3f8815fb42c8b4f2dfe4e82e03cca0f91a5cf63bae), uint256(0x26694e86ff4f2425f0bdaadf7066818d1821e148663bd53e5a24e6c26929af1e));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x21b26e2e1c1d7c82f3fa69e676be22105a19a6eb5cb9e8e66eda60dd6bd0f82f), uint256(0x2481f8d2de84b4969edb3064ea8d6cfad5243fa35edf37ef792e974fefa80b01));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0adae38116a39470dd01e455b8d41d6545867acffe54eb48ad807674941d96ce), uint256(0x2843baa66c5e6714dd060cc0f524ea8f492d6e50ad11704c1c86861612bd06b4));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x0a2886f64e0fb3c354cf5c35087a57a958236faa291251bc7bcbafbb5502382a), uint256(0x10b19f41d8875857c8d7c5500b7789caa90e20f07938c423645e8cae32790e67));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x03caa72b70745b7df44f1f5403f6b695d646faf10994a5332114c84af5c3a32f), uint256(0x201aec43131b260e889173811c256a3305a06466c89e678ea7fd39fc12894d21));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x23859859f1197efe45c8702dd4709af9a68b2859fe06279292c93a37315bde12), uint256(0x0bc2daafa820ebc7ec84d9fc881d460ad12af4bc2d3a143a08bad561ec4d55af));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x108fbae1f593c771337ec1daa64867cd6310b1fafe0c35d792040bdebfb7640c), uint256(0x073d043d198e2e104e65a19538c8f7b72176a6e27cd0e9ca679c0c83b1133003));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x04d685c05d85e9e7405b929ca2464a180729fa35f9df468cae5c2f8b6c47aedd), uint256(0x04c0c547d555b2b3d2aff7c7d9fe6a74dfd6849f38cfc69e67e82814445be128));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x294fc04c61201a9881ab0619d1fe6acabf111e7d798973c2174c65b702685838), uint256(0x0a3b084ec6873d11ce4ee0694c91f87fba40b7390d73d27f6bc2bc5ef3812e39));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x0e8b0561e8b7a6905801c68bcd1a961a658b5eb7ecd94ed1ee43c5881eb2f451), uint256(0x007a69109c6a8c7a13773ea3199992efaa38b25c259de8700294a17552e876ee));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x30012dbf70789a34998364f60d318f74d81efdcefe102c9800363e8e17c8d1f1), uint256(0x1397fbdf9659656301354032da5ee3a6254813763257e3542fe65ee059a7906e));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x10e8f775f7bca4783e3c9e5dbcee875f812753b827a52b4a419003b8b451138a), uint256(0x0ed1df0ea22c3ff69f0d1847823ae7f75ff08a00fd0eb4fb02e802fecc6611ad));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x0e2dc7ec5da3cd99008abc17c2b8eaffb6fd15d1605e304726928911d5d3a711), uint256(0x06f7960e7298e184a5eb65dab03985c227e02d125fa653a669aa7f962fab2160));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x011fef9d546be539d442d67abdf0fa2a28549df261c92ed24b237d070ee1c9f3), uint256(0x013d86b00146b6b3e5f77d06c0123259e02e1b3f08ba656bc0fe3ff92381a99a));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x1c4be86b043505d66e33e1373d011d730c8fe1ee41e6420ec29c07e22ab7e833), uint256(0x13d49cd801c21b1a0d3091293072bd468232e744f96d6669fd158f9cc41755e0));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x04855aa76227e8aa1815c3bbdca23cef2b2b1a450483446281b7f1db3dc04a1c), uint256(0x2e35dc16518e049f07b4ef75850dbab7f22ffc2f42a8ae80367b81c97a9100bd));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x0cb247b9b3506450671295f7ddae40e06693b1b00e243fb304a0799adefc4f5a), uint256(0x1251bc4d13a94a8d9d50e919f58660185422c34a26a295b925fa4fd41cfb7403));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x253968a5ec75cdd68f5f30240275d62bae94da7ddbb8c813c870a13fe80222d8), uint256(0x0398e779f4183d7644f2f12b0547e469a77d9d30fcf7ef9910a013cc71bf2cef));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0418f799c87a2653980101944d9d11b4051dcfa18c7a985b0b49690cd450b160), uint256(0x0c32f12acae08a8c031715ba22372f22baff7cc2d321c9c4cad976ccb67d395f));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x06bc4819a0e8a57945811b649503ae5b93c77897d913b1300a27f83cac7c1448), uint256(0x031d50d5aabaf8fd248c0333c7f32f183317206b5f344c319b83e879fd341819));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x12891798f77ff8116452798af75e9e36e7739ce7e67806cf34fde04035342731), uint256(0x12d3e6a01c7c804f17d7bca3ed7beef7447352e314d29016ab0dc2b540f694cb));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0c74d8f62afb3206da7ca0663d361f06a6b6329aa74055dc4c68020bd1b17276), uint256(0x297241ede59ab3d0c61929df61db59ab83951303a5e646bd926bae932ac0eb1b));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x29a5dc24503f329bf38472926243317916ba284668c9f93d20b123bc221f0da3), uint256(0x170a5a16393f2af9be8de62603aa70207602f3dba24464c542c7e2c8c987d10d));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0aa8cb73dc5e5106f8376da1127dc18a91294f25dcb276c9301509a27c82b921), uint256(0x0a54a51a8d0aae9806370888fbea83398c58e823296a4b06c651314cfd376866));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x190df15a41bd103bbadb2a0f9918f6385e9b474337c503812fdc0d768f707a04), uint256(0x0497a5741744e969b4ae2e2af1cd3ae40c140ecea7381148db078130428a8860));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x12a328103b682fbda3bfce1689614822fabbf92b2319febe5e823ef27b0d1984), uint256(0x238afd7f8f0b74dcf4f517a055e7f61647b01227664647675d3e57450b7dca24));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2615facf3565486429c30b8b73fe0348b3fb722ba299dd1c42f6439c6728392c), uint256(0x045aabbf947de42aaea126f88436a8973d11b65a3cb75719c5606130d438f4d6));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0c9d8da232523c2053d48c739b3a29cbd5b91e7ea548d1a3703fa03e2fb85624), uint256(0x270eaf2b40752c9b9887cc10fbeb1ca61930620cfa983713f57ebbf1b20dd9df));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x22a76af8f74e261fff3ee044f2dc5cdc5d0c2cdc3f3ef70e67287f49591ca42b), uint256(0x24238a163890818ed4fe29241354adc2be66fda376f2922d5114588765ff4f0b));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x2330f9aa69b8cf6ddb6c16dba4209c6c238bdcd86c799de488d20129fdae7eab), uint256(0x00516a455ae154a0e5106d4fb6668f21d50a3ee7c1efade30a0d91d9676c76d9));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x27eba9cdd0d4e2bac4e7e435a354c33d1cd6316c31e19c37d421b1ddf9fc191d), uint256(0x0a275be86300b421c2a024726dc36056743544704335b918a76ff5cadef1a2f9));
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
