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
        vk.alpha = Pairing.G1Point(uint256(0x1900c8b3a13463ace8fb28ad6524fb266508b4e7069d5b6bc92b42301b09a731), uint256(0x1e19285fb3e9312c41dc46bad50cf19db37bf38e2e291fbd778b9e9714cb7b09));
        vk.beta = Pairing.G2Point([uint256(0x18b254720bd4f8120df08cc87361dbe811151a0ac95655a9dfa516c80e98b418), uint256(0x258da34c605b96b347c6bc6cfb469ad547f792d26ca5b2080fb5b04b5e2d817f)], [uint256(0x0816d9c67b6ebe67fde30a721d4760d908692eb9c81dd70087bb015641e66adb), uint256(0x0cedc877250e09d0e126aaaccd88ceaf7c74baf98dcdaa6453bbc00f02cad8c9)]);
        vk.gamma = Pairing.G2Point([uint256(0x11ae5f17c1fb1be460035281233a1beb7a78f10ad635de3db7101a1bc96f4e4b), uint256(0x070751e5162a03579063b75abbcce9a760b6f1c9f46abe5e7f8f20889954ee06)], [uint256(0x0c7b8bd5e22d81b735af8e52a7bfe7391193b8ef48375aef87b5ff89ad5871f1), uint256(0x168e3ae4287b898062e633abad8bdd5f78bb0214864eb47a333ba437f67e78e1)]);
        vk.delta = Pairing.G2Point([uint256(0x2bbdee334f2846b41637105d9e1d4c29031a89ab09b26077afbbbb82d045d998), uint256(0x29350fb846802a715f1202f0a47e7e79d2c491f5bda6f47ed9affd1b96ff0599)], [uint256(0x2ae34f249323a4b0c0950d4a9e7a046d001b561c1ca58941905e2678dae3efaa), uint256(0x116a78f6283dc5a4036bb4a442f144888b61d6abb214b6b448a7f4b8bdfa62ac)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2bad41b62d32319dd4b3be2e4f0f28f114d80e516104a0f3f78e06d934de3b1d), uint256(0x130b9d2a717d7852fb7fe12643ca4f13568084fd59e8e08417e99c9fd2088edc));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x2962eac9ae2b09c3a2e931999deb6a44b9ee84b1699170e6772567481bacfea1), uint256(0x1fecadb296b68112acb2c212e46d6be1ca2ce9eb30c74042eb1c77b36083b008));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0ea46ba1b156d6729b0deacefcaa8b57860f68875c6bf54661733ff1707e5855), uint256(0x2eab607b3e752fbd7dc07cf0b240344005aa29b2a1d1b145c75780b632b82d0f));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x08439a2872dc18f93543a8d4f668f060ab948e1949fc11c1f7183ecaba2d2de2), uint256(0x170e0ff75c37b7bcaf48f83f0558c634d21d57fb97fcdd7b22efb6d3ddae9b5f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x1f4b9f980071677d2f95e5a32c0ca820f7bfe6fe51ad812afecadb4fc1533278), uint256(0x181802bde1979a4d3f19ac1e7654e795a641675f2e2f60dfec9b49b7a047e639));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x0404f7ffd1efdff6f3a5a05142408ab4fd16bf20cf2b81929fb8c035bad5c1c7), uint256(0x072b05c2aa4c60b2f3ee716c4d6ad7a725c0ec7a348f015069c075224a0581a0));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x068f20351cbb1cd305ac9f0286cc003375299d620c0b11ab88c178d6e1362e6b), uint256(0x214ddb4f869afe4ffba3861f58a8b285aa7b9ea0a8c9baa2b0133c528043c0fa));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0838805c9f7b62a02238c9c169a274e2ee4a054e6251eb8e48c9783159e459b9), uint256(0x0dc73830d4d27b2b05dd415a060d6823980c7a528cc5ea6e780f4f285465b95d));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x07cf96ef0375b26f40703e2524423a65e8c3e037dde2bba43c3c0a1abaa29a25), uint256(0x199dd1024f58d183149de1ef0e900df9688b0e076604d6df59a0055a2dedaa35));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x0f5286b3e1f1a11ed3aacea78d5c77555cd3621c2a53c1825c87c5e475f88d4a), uint256(0x017c147b350d38845ea34f47ab5d88be7cc02124ab4566f45572dba041be9768));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x1cfda58e50a6c6d855540ae2b15894318ce629766c6d9e676555e5325de1ea49), uint256(0x2c749e96fc3af645a71b87100df4de2d1edbcbc3c835e5eb180ea4e4e8373ba7));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x20e6697111e0eb683d550fb3c4f00b441e8fde961502bb203dc6df62da9b88cc), uint256(0x14b8b1af2ff36f008230840f589c1bafea158b148267ffeb9c76cee7cb6c6487));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x04970e092572b81c9ec460bb9d3f65fdba2156999fc1fea0fdeacfd3276ae50f), uint256(0x14152d19d3dab51f2eccb4fafe45df229e8b296bc5bebfee9668d917182d6267));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x03fb49ad999c9b118b99ba90895f94712745971eb23406495fe5dad8ef215cb0), uint256(0x22efea46a4c64323ddf5120eeb33e8d735fe8a33528428357b620f5cb76a6aa7));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x21bfb6a98aabbc7551825746f211aa7c4f00eb411d57faf8d8e5112e35cb95f4), uint256(0x18fa510f698a685e25d9b09f12cd322ebbb1a54e58908910201b22dcc0139444));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x14bf7369036941c3c0ba3ad137787358dc3778f8dd1863808ca19eb73cf50e70), uint256(0x2a2f0020cedff44de6c8a33bb7a625e9ec95383430a296e25f0ab37925735cce));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x0d6bd5b2ff1117ba7b876ebfb5580c216fa70fd669c766f04a7a1de383ed7a14), uint256(0x2b945548c2b53d6f7eb48ce65719b70630f89d1dffe5a89887889d89ee76ff38));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x105f9ae3fc2662e626e3f0eabf06fff122c8be63b40d7ea0c5ea6c85a77347eb), uint256(0x113b2dd5e956e59c58dc6f475d57bccdc9e05659a189d32cd7abaf5b7e378fef));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x18e56f2c9f288f34d9a4e1235949657f44dc51282e2d4723ece6018d68f52b07), uint256(0x0972eb0d14c841ec0c1cecc0804c24ef252b9533637b802f4da8a36448454567));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2ca5b0e7b72eff0765264bd8c279714dc539025994e1a8385d14b6b1b43cb6fe), uint256(0x00bfd77a98944025f5c75a3eb94b32d3b4f6c880c58c5f53415527d5f8941818));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x122506e829122359f48ba32a8ec821ff792b76ca99889f83de409b20b8d6f610), uint256(0x2412b129897f1cf18f1add6a4ae66627c9cc085ac902d3a68acc24c9424ab153));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x011395f017390807164b642c1c3d64d601af36cdbfd96a505162cb8f4c85b130), uint256(0x23b497c745b8502e04d9c89b8011c4cb3a890c0e31ee36c7ae6acf58e6480489));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x1d64500af6f0e1ad97737e995ee1cb27c5df8725ec312a1994eb8e0e6aa3e43e), uint256(0x27ba1b2aa9168eaa63a77035e698cd3ed42331ebd29a9890786df9d680fa31d3));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x030ea6275aba934e985e7d003334effe405dfa3a7ecee7bb3fa7534a00fccb9c), uint256(0x1b3f74ffb589083581265bf1a4bca36f9025f74646c5081c29d17ac961b86fd7));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x09b9322e4dacfd7420f76176595d24f3e565ffdb603ed5499e15283ec43ba052), uint256(0x1efbef96637bca66a8574ff83056f76da947eb21cbfcba7f4dd75560c515f6a2));
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
