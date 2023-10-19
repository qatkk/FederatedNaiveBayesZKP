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
        vk.alpha = Pairing.G1Point(uint256(0x1635d15567816b533b8489291dfa7369eea8bfd26b1a5661d43b8fba8534ef93), uint256(0x2f8d32ec4a8df92a5c58ae9a986b971ecc205fe221c30c1f270290a70a9102c8));
        vk.beta = Pairing.G2Point([uint256(0x1805caa951180dec37d759597459c1bffb3a7ecdd50510f34d8da841fce78b0e), uint256(0x03d678fb93c8c15c209dc39869ded6fa699436fb5dc53a18d4ed5cc82ea056db)], [uint256(0x18bea2f33b985e0a57141e38f3a822f2aa8014ae1108304ea2832bf8036ac0fa), uint256(0x05b60fa4fa9ac543642a610b35de6731cdca3dfa3bf02890116e83553bcbd653)]);
        vk.gamma = Pairing.G2Point([uint256(0x1dd5f5a44a5bad3bc6a081a9b003e0a5d4d4da40f5385c442f12fba3be9c2235), uint256(0x2feb231fd70bab785cdcf0d021f9d9e5aa536d9e34a552fe1eaba06955acb7d2)], [uint256(0x199bf111819b97e857003a450206835758256ef87bcad43740926cdacd01d88f), uint256(0x0ef180b448760065b8171fe9e98fdecf28baaec92ef4a9f4c842d11481387be8)]);
        vk.delta = Pairing.G2Point([uint256(0x1865833bb8d626ec55310f1f2afa37bdd778efe48c28f2045efda757672f11ba), uint256(0x000939d7a1d5d9126cd182e681747529bdb15c0a9fc864e13a4e9862fb2fb784)], [uint256(0x178a3cb3c4b7177652321283be8c4f2abf6d1bde78a09af571768514bccb795d), uint256(0x13a75eb6f0dca762a71bf75b915aee9c3edc9f0842e2c4de8a6c7337ab389d6f)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x095aa9708537e0acdb3acb11e553515ad1f65f0001bf4bab66dac26f2453ea83), uint256(0x1ab0e84d6b24f34f7efc79de9ddd6d80f9380dd8c0aa28c32e2f9f3854ed97fe));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x1dd56957f3368111456308041cc4c36d2328e47592bac23bff4b928d8f4840f7), uint256(0x2727117161ea311ad1dfb6cbbddbdb59bfc668da582c3024c53564463f231f19));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0bd92c03010973077324fe3f7b336e7e35e904f71001cb137d725f9032fcff7e), uint256(0x27e3d009cd396bad72572be54e443025e67968e4c4b6534bec71131d44dbf855));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x21be2f81d87e60ebfc7c3d4e5045be3150c19fac919bc96935dcf5fa71ec317d), uint256(0x0e2f428f967948026ee72a7c84f5ff2e192fd04f427b8249e4dd9f407ebebfda));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x295ef3639515d0164396ff3cd09c05562a4f014ba4305fbcfce9994bfe9e0353), uint256(0x266a66fa705525272000825224ea26255b11488bf168a429b8c17a220bc30557));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0006293ba7a0b33ea3d746c05654be553ba0b4f2cfb66bbcd19b193b9751369d), uint256(0x14a074dd3543f4ccdd6537ca5c8eebfb217060ca4e5afeb0a7a09d9ecfc912ee));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x144ad0200273fa50774c9b9887163281953aa2ab259be53288879f063db3eb18), uint256(0x206308bead896eb31342813e8e9312c5f13dd471c0a5605de66f6f68bc0a4126));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0866bcc288edb38d7dcf46657225cecbbbb116d7c348584d74b4bdd46a511cb6), uint256(0x23d60738ef43938ecee267ce09786cf3d18be5c361918704585de32e15ca9e2d));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0b2f3bd45b06b0f39cddb0365a8e2962ad9e266e7d718e62be89b4f71cef1012), uint256(0x2271ba3aa61eb2c10d848935abe4de30dfd4290d8266d615921bc860a2a0adce));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x23fb3311c76f76d0f26729dbca3df5e83ae561d2178e6d65497c816fc502e66b), uint256(0x01f9762a3514bae45ea18ae195d96d06726e5b13ca98911675d65baa81f13378));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x277c7ac0ceb263bc9a3d014d38a6000aaa1c42315530db9e61fd39af8cbfd92b), uint256(0x03c17ecbb1f7f2526ab2b29928b9b88e46934df6f584efc5f6abba40250f9744));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x2c98470cb570e485c786af848696da00486aa0cf3420215c1b7d4abd50592860), uint256(0x1fdec81895854c21729f47cc08a2a6dd6a791a99002da4139aefb53cca209d8f));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x25a81739a99c738161a6210eedab854a741cc0495f7ec2c677367ce3d3e868a8), uint256(0x0d930f83e7260ab863230504290cc7d5fc0d8a1f07b7df347112d72bbe9437a8));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x07386e63ab5c69a165a8b0eb0b24988e88a1dad8191b324a458e053ad90452b3), uint256(0x25460f55db0d23ac0c824f23c61dfb42cbd4d9f4a3cbf0f912cc9434afc00123));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x274482c081cdcfea7f907eeb48a54589ef7a3c2f1f5d6b14b2079fc42019851d), uint256(0x2d3269eb78a6c30707d86790bc9118c6d73e8665c6426aae55118d4bdf1d5141));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x2a902536485f315f958e1f58428595d9547e508a44fe4eae4d88490f7b6f4935), uint256(0x2467c22389a6f730256f13ef9c36fefaffd5f62e59883253ba7e454f203bb1ba));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x14629ff0a8b89bd71c2f6a563bf7c970ddae1b321a9c7a166244c04530d6b3aa), uint256(0x12c6f2e374e57df351930c8af85080f88aaf982fae8462f566ff130fef03fb4b));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x26fb68fabedee09dd650447c8ed9a1facd2ca6c64d7ce4739f9ad24e3681a950), uint256(0x1451295dc567532a2faaef99fea2d36cd0783ee3bab10ef347b04144c56aa1d6));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x170ef8b963ad4003ae5fab8f63a3498019996cb7e95abfc8bd02e146535acc00), uint256(0x00c1aed28ba067b3d985de0738be5d6062ac05e671c096dd545b49509521ec16));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x195f188845ace50740d4e5d790923101f03de4c87b72f2ef9c13ec43caea1c42), uint256(0x1be80b0a4b27caa95e1f4e05f1eed590581df670510951c7d53c740a78aea711));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1dfaef7d1d60d28f24b48fdcf3e2002e60bd6a912a814cca9a0f50716fd763a4), uint256(0x2710d6b35bc5a842e5e0a66328fb88d23dd81f1d857223b86e57a1d4028ac224));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x29cb27efcca93c2ac44427cc8a10b06dc8edf7c9d5d093a81111d303a3077d5a), uint256(0x20b0649741427f3c0888a7790b93f647fe16cb356d05e7e1b32c7a8191ea7166));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x031c3edb5bebce3517bd14a98d56a194bbe4e61efd4b25316a2bb768488fecb6), uint256(0x009cf640cc8ec2e09513ee64fe8602a365e040d2adc40be06d3130f63d00dc67));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x0fc00f16735e56e0e1eeee6aa1ac226a8e88f89f7f7139f5291693e13da95cac), uint256(0x2499b80bd4f366c83f2b4da3e013700a00d1ca70649256b5d65f39ad4c4c5db4));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x1edf8272bddacdea24c9ed9829c4ece615c87bde3e8a387faaa3f559f036fb8e), uint256(0x21601e76e5f68d65ead089c6a6ecc2605416263352d2ea5fb9ef15ba239b02be));
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
