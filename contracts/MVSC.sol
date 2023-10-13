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
        vk.alpha = Pairing.G1Point(uint256(0x295158e94a5e0737ed6792aed538a1023d8d9bde8fc8951c619020177c31c187), uint256(0x22eaca57bd642abfab2bcbfd7b9efc08e504c7b99aa394450343250515eeb42e));
        vk.beta = Pairing.G2Point([uint256(0x19e80f30b9ac8318aabbe8216f42ed7ceb16227de00f9c05e79fb77c4bbc6218), uint256(0x0c9347db17996f20b34d6a03680759c5eede18ac301443e9fdf15bf8047b1297)], [uint256(0x22bc2741bb8c5603e8138b4952c7b268937716ec5bd8b66dd482406d193d3367), uint256(0x00b3ba3ed3087864d5ca9b52f8e7a4369a899b332414bf07261a408c97627187)]);
        vk.gamma = Pairing.G2Point([uint256(0x0b8e357307c9ec7a350b2504c00878ce1692052d724dcdbb8767c9c7941be182), uint256(0x0d35a147546c73ac55d31dc2f857158d019630b4dda952d368e5cb2dbcce1dfe)], [uint256(0x0b1021bf41dd8d3dd3f3e4a2bf98a6fc7c87a1ac119b66cc68ac5d0703029be7), uint256(0x2b71120aff3714917d85e1d2e4474aaf2803fd98de542228f5bdb89b3eadce6f)]);
        vk.delta = Pairing.G2Point([uint256(0x2481cc8097fbf35bb48c3fe0d7729818b62c48fca4525ff72fe4e0ad075840c3), uint256(0x0ba2ae74c8d5cbed796e955d8c2c2661f00f38c2ace41ff8445d1954dd80db92)], [uint256(0x18147a25c82a71e3958e914718166ee21e05b86a33a7e76f814e0547e945469b), uint256(0x204b15ffbe16bc2f543d5ef4df32bfd703ecd7857070c20fa1a5e3b2734f703a)]);
        vk.gamma_abc = new Pairing.G1Point[](25);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1453f0650c9f61e611b1af33800d0dc4ccdb0fc489178562c9f52eed9bb138d8), uint256(0x0b5485256fba5fe17aa9a857817e2a40b9ef94619d225da7d2239ce7ecae9848));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x19b5bde16a87fb96f27ac49478a1f7de07ee60e457d27273c85bee2c1fe61d76), uint256(0x0bd6b6c534c25ba9c615106d6b63be347090898e93001a36cae8ee1e331938c7));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x1676a880c9726e92cc6aac91d2c1bb3c206e80d62fa48956f9ca47a4b102dfe3), uint256(0x0af5764fe9da531fdbd83060b398db509f155ec2f9b9b3a6bf31ef53bec85879));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x181af7c6777b2818489f0f1a14287f698424ee79c47575c927496c11ceadff01), uint256(0x245042e2a3a4af7551bfb359ed0c1d5e90d7055c05ddeaf319e90332df6da01f));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x27c44ab233c90a2febb4345035905701bf80e8fbdb7af5aaf862a5c3ba17a34f), uint256(0x0144323cea3c963c834254b649266a45cebf2e63eb694ab95073df2f5921da51));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x1c401d6781589f73b921773b00573a6685c978723e041f5900c4a7fa39a68773), uint256(0x16d4a364c3860b5278ee988bc0bf05d54ca6229ed29cfef14336db364a833937));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x246b0799a283982e285ef573ec4f16c6afb1410e0ced7fe0d3484196edd52afe), uint256(0x20ad9b228bf53e2fd9bc57856261b00ab0d26bddbb4287bf5b6dd7b2cc227122));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x08b6430c2d857c685936755f503f4545da5e7a644b7b65bdf3ef31ce2906daba), uint256(0x2f136ff7c89c8195f78758f792828be3235f797fcff83c6d15a11fda388361f6));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0bd9e36893879169ce1f6581dc4938fadbfe8fbf09bd58580f4e19da739bffe5), uint256(0x10f6928d6ec2bceff3970c65a5f29b44396f7aaef953e53cde3b53c9f9980426));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x1ca2289dc446c4c25c07ec2aac10a8e4c9df04eabaed92b87fb7a0742f7a53b2), uint256(0x223ff644c4819dafd5c8af17329c909d07b56e39abd2d8972eefd609dff7fd36));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0ed5716c3d520a5eb9eb8e3a8b7bc31242b16b1fb29624ae75202459a6b4a5c7), uint256(0x211e36cf76520a128cbe8f9d565809fbffdedcc50160dc2a0d13d7168d6dbd17));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1e21a9842de5bb18e735d1bcf4c9eae087ebfee4afff340215418996935e3fef), uint256(0x28005099b67ae878354fef1f1e087353691716b6fd2bd64a27dac474ce8167ce));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x1ef37d096d63b30161e409a1ae0592fc650be7809bd5f9af87caad7e58e3f062), uint256(0x247bf310d90b38e0d0286058ba016837478fc7e0a53c3fd9548f4380557789e6));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x15fa73d893558f6e68c9be3bff25f6364f5cad9a74e574af5ef1a45fd64fc4dd), uint256(0x2b400bbc1377bd5d0233bb9b03c61606414311992464760a36ee427357e68552));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x1f6de256307794b9b78621f949e266e646035c2a74f768de7d9eaebaf73aa488), uint256(0x15095f97862b3de7cdefc9060b728000498b6f32145a6394a7ef256ccd0ce831));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x286228979ac8a77b8a56c7ac7e2238bec7c90dda7e420333849f1d6d7e3c0450), uint256(0x13d0c73708b020cdf3ad6fa7664af1187a3b10af59c1cd55621aaef6cd0f0c8e));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x21caeeb55f22589525616d8fe7519ee8e0064846a0d06f2821fee6039f3331de), uint256(0x0f172ce92badd55371851bbdffc27a21f2e218d75137dc52a8c83d52d4b4b664));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2cc3ddc2e331a2d0ce2738ba945db20fd93dccf4b69552b7a306254abdfe48a7), uint256(0x0148899b29019aa2c9cb797ad30e084c4ebf8f182c0796a651b88078201d079b));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x2a326f7d21c2fb462f56032de8cded0732b519cd46f145c71ad306627af8b0b7), uint256(0x16216de1ce9b35b53d706963412baae5b9151a0d33132ac67adb0b76c4bddea7));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x17059027cadc7f356edffda70ee56f5e265d290f4caae47fb0f2afcdb09b3447), uint256(0x0732612376a05ac150f82ec288d10237183e8a1624b9546f0e000dcaa7b1b9d0));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1342bcc90c710d13d9b2e93a4b705c3d4e448b2a35f31161f2535368042578ea), uint256(0x1261cd2ad7e437f43c539c97d9f6b95e1cb46cddee3f8201a61088a82e3eb932));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2d0b27c1dbcb280ac77cbd22d9bdf5628ebfb0a5660cd19f7fcdcefd204ac7b8), uint256(0x14c1924195f12c93370cb7766050256b5abd69a40abe70c6772edb83700c21c4));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x0f1f28bc0876aa01abc5c51370d4f85660aebec6d319807acca96c7f8fe167d1), uint256(0x06aec3a6543645a7a554e70cb057a751cbd8ca19782b1399059cde928fbd6810));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x15c6cc8084f467102f590f5629f0beedd8907bb2d4eab67287320f634eb70c51), uint256(0x142fe49d6c0f54abf839323f4aa8a18c124016a816d3baf3f1857fd12fd107e1));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x25aa3183f0f7e3709a62cf3a898c6907d9c6ab81b4a9a6df48d8fa3aad17495d), uint256(0x2f9fe819e18962d8de1aa2605e95253653d629ed8d0107905c454a69c191b884));
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
