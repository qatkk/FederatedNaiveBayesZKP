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
        vk.alpha = Pairing.G1Point(uint256(0x2a320c1b21ee1327f935ff704b3ad4ec7e7a2efc0edc8476566bb9e4db091949), uint256(0x030f4eb51a8b4418390195b061d0f1acd094f656d1b30aa635dfc802b6238d1a));
        vk.beta = Pairing.G2Point([uint256(0x05f0d1eacbc286a5d6193bf30e241f03c36eb1923d5d9d2e0f56ca77899dfe17), uint256(0x1c01c67ce3cba23b14db8b29323e797ef0084a379b46cbf39345f6b69444fe1d)], [uint256(0x03128cfcbe842fe6c31816de732a531d89173a1f425f25883a7e6288cbaa45a7), uint256(0x21ee1fbc46c359b714e94018fd529353a2d627f5bfed583480be6740955a844a)]);
        vk.gamma = Pairing.G2Point([uint256(0x1af323401b6e1e97686cab89f9fef5c92be317e403a94177dd28c6d4fc4ee7f4), uint256(0x1153da15e1e994aa5022a92c303d3e857bca56e8504ac3214806db272ff61a7d)], [uint256(0x0d6169b65f082458baa8e5143ae136797e82ae645c299dfc3a17db097d80aa3e), uint256(0x2b7f7304c6f106b2c8d1b8a13142107cb61baa6025448bc26f8d9b33ff0c444b)]);
        vk.delta = Pairing.G2Point([uint256(0x1ee380c0ae4e5fb468dfc4dd27bc94158675ebb62c1d42284bc514ab64aafeb3), uint256(0x229991ed23ff05f92b6e0d10c8af8f9e63cc5b0bb4edf561d07016295387e792)], [uint256(0x0eeb45c55d795e36885e5165ee0bb2608a857486990b1bb9de7a5ae7f9e8fcb6), uint256(0x0d678a1cc4c16679f5ff27e9b6573cc50669c583fd755bd2fd7d4150e091df60)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x2eec76870b39b1fdb24eb3159347864502eacd4669c9aadc0ba846478766673e), uint256(0x2c87f04dfde7e74eadca73caa07ce64feb2dcb0a7da4b9b1a25533a1e27790f2));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x11ae923d5a962c123c32fd79d8cb336bae47ca93dc2c307dded73f703824f61b), uint256(0x17b2f1d121613c607dc933e6a06bbc35f4319d579b711892413dd687bc11f3ba));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x0f2f64163486d5b8d1a340368a2e19857bee2b003d10de40319cc7b3914f180b), uint256(0x07fd1a5f72c7586786abe681eb61fcd18dc4985493e8f3bec1a2fd0c54d5c7b3));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x23abf14f99e7864b4145da07a67f6453e1a8a29d0a06ade88b1a0bdbe3eabf42), uint256(0x29845b85a9496802f9bd406c3f130646b072a23765d615a11e30594be688a889));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x18c377841063bb6775d6671cc1a0515ddfd9f04738d7ac6ef2b7183f1076836d), uint256(0x2d77d62b4ad328ec1dc79c6b788aebc91a23ba303f3d9bf8d0aafb12876c66b6));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x2278169f36fca801cde82d281fbf9bc7b9afedfa05a6a4af55d3d4fc73287598), uint256(0x2cec7d74c6e7439a177188552389143963085188d634f1aed144aaba242c4a45));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x010abbe182330a98eb186cf0a8f4db00b79d7c5349fdb53905c0641cd9e6421c), uint256(0x16182992983a50794136d312bcb7532d4ee27357bad1764aa2ac3c41953dbded));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0873aba03accc62f4f873300fec03df84906056ebf198ad34983495a0be88c86), uint256(0x105e17ac35f48cfbce54115c6ee6574105239d4e384020b8181167239a231d62));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x2631ef351794be4ef66050917ce6a2d79dab9b9a0149a47486593650c574f0f9), uint256(0x0bc09a3ba72d3b23c4b11a8810686fb4a0493092a483df5cbb3d96f1ed5e544b));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x2d9c128fc4bb795fe13b6e6b406f2983645d67d3b34139cf58d51af05d87ea83), uint256(0x2b82b1aea35defea4ba948048b0e6d30f819edd428661f42b95315c02ce434f0));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x26c84957efeb57b891d5e42ff7a79333c8283cd09b038de9cb42a97f4c2bb341), uint256(0x25d226c767fab202fb7210a5bf60006c35bab6ffa59d954f7ca748dd7e0820ac));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x1845cab73d68dbd439081466965066dbc438b20a7b804ac7a202682964f87195), uint256(0x07b01a650d30bee3808c04adea0d1d588a62c6f86925fea5ebc76287412fb135));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x186214ccef66946bd228f88d3e3cb9400719daa393ccfb70b1d5e9c905308f01), uint256(0x03c617966a0bd2ab506547183729e15afa13aa858334f9ce77efb2985661371c));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x1ab8fbdac5ce9c0a78565e25e8ae545b3da0f027e7506eca328d7f4dc6e168ee), uint256(0x1f2df29741ab06e7c390fd28c53dcbb5a996a629b649869cbe3762056ace0c2b));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x0c15affd48c85ae9426c7d5942d49c0e0976376f23600d350a541c3d35c5fac7), uint256(0x192660067544fe29f3ea36bd089d0b39b67ca6cb5c4cadec48b4bd6a03a57efc));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x1e623091ff3e85e72d0942533dda02f25415d7ce2794d61686cc02dd897ea7b1), uint256(0x25dd2b9311fafb27b32fecc880587833497a935cda28db8be6bd1abf3697eb02));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2d1b37654cad0fd9388fdc37166f0a2dea18c8a4301a048563c319c8b190243a), uint256(0x0f6cd74c6b19677cbf9d8bec0a3fd7ee90f8cddacfbf21ab55b0d089064fc773));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2f2889dfb5b6df989f5024acfb33d2a8fea10da3951ca6c60dd0d44ab88ecabc), uint256(0x179e47dcc3aea2288b6dcdcc61b6644440baebb473aff026e634901634aab397));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x29b7147d046da4c5403bb39feca1aec3629d7aab4d96b5202aa75dbafff4f94e), uint256(0x2d439a25eb14429dc120cc4d91421fbe54f0ee64f5f88bcede4df51471767593));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x060cad95ba853e344a67014ce090815f8efc9d98c95085c503e1e1708c2dc1a8), uint256(0x02a44c7fe5a6e06cfa63c009b6d918b89dd1bfae20c5c15c7fb6abc1b74de0ae));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x25cab61b0912ba5ef7f7bf227d041de29654f270264f67523a747033012d9abe), uint256(0x006a318cf7cf1f6a54f4309dcbae0c15474af1e7aae29c9c176c5b73ffa3e43e));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x0346cd3690243e511c67ce868de784750d109f970fddba9139a0d5661e9a3f42), uint256(0x0443b6398dcf843e0b6c46ef7ed5600ce9e6bf82b513eff1a66f3a8355f60972));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x054a71f471ee1f0e718144db6085d8a1008b2942c59de6403db50a186d07b184), uint256(0x175c0cbb5e1a5eea95dd726616b8d7ac94cd848f8318a97b9bc1f9c0679ff909));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x19fa8b200dffe11b4b44918babe5e0499026481588f1b6a2dee38039a60029b6), uint256(0x0057a297bd0babc76c6d120d319b61d2bb2946cc3890a7108fca249761ec409e));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x082dd0ffbbee49ffbb9a5fb2ca853da0897ba521a049ee2142c03a5cb6fe29dc), uint256(0x079c638dd5b108aefc22e676dfb66ea09f16239a15eb1df4553217cddfe43454));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x0e49da5e39e1aff4467dcb6778e7782388b1bd29e396f851bd334b8f3f94ec5e), uint256(0x250456930917fd0631fcdffaea74113fa4e90086752ae1a81a3fb13801cd6a57));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2b5bf155c51c7eebcc11ddf42efabf6025b7ffaefaa99929da6451a4598470e7), uint256(0x25d0122c36b08b1742d0fb9cbd1fae51a2b71224afc8f356946a6204519d3826));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x1b8175b811fcb4c95754d20e44c1596acb3002c7123c0d00eed537a9b47d0fc7), uint256(0x2e52e8a2b23c6a55a614c1db5f20692743dbe9545b25c28edfbe82b2b7570408));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x19a7b300475253cdfc0561ea5e2aa548e8c0f8067cd003903ed473ef7015d3ad), uint256(0x284d7368654bc84f3037ab26a584c6a54b24f562ef1d2f0cd83cc3eed1d0bde3));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x24e40ee4b381cf9336b63616ed8b529f098fb7b4898a835ede7a99c0204072d1), uint256(0x0c0841a21926bfeebe12ac95cd06ab6e039a556f2b73ade7f60c3281d5c6c63e));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1333565ffa0c50d46c005c285accb1198c39cbac67939df822cf9b31f6b6a3ec), uint256(0x104bcb58487fce3ce89cc521bd433dd6011b2d3a36403bc3c2dc9250358db94f));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x097aed0dca7c6f99fca527843ad5790d4ea55d35d7073ddeb8532c9c3b315193), uint256(0x19b857eda3c8020c445f666f7371182986ec3fcd4a026b0dbd6992b28a5a363a));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x0723fee7a4928f1adc6fe3cdc0e9d0d3b5a7177edc94d79b1966b3230f58c039), uint256(0x231c3f8eee8d6fa62a666e5779a52c15102b9a8fe931a3c721dfb1a4300c31a3));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x08122f9681fbdc8caee06c6dc28956429649c23ac3b50666bb9dbfa59991b394), uint256(0x265ef908293d059a2e339c185086e98f920bc41638f9797baf8021cbda03c004));
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
