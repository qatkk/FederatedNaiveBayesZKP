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
