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
        vk.alpha = Pairing.G1Point(uint256(0x123633f9f3a90315565f0335cde61ffd535f5f0c6cb5c9539e2fe15f4b17c575), uint256(0x304ee6453ce381ef9abfa4df771da3066ea7c1ff33f5b8cab18fd7880140421b));
        vk.beta = Pairing.G2Point([uint256(0x2e6bdd82afd6cabfe99f639eb6476b25d4507d11c083892e30431cb9d0eef6e2), uint256(0x29fa51430f6f7f6aaa00839875e7734f5b3cd9ae5e5b3ea3735056cd1f74c2fc)], [uint256(0x25cdabdf9a033f2eb14717ef2a2c148dbc06a357a8b36e50b4372866cd653e2d), uint256(0x257650506ea5bd14b8a14614c789100f6d1845bb4a35776c472cf2ab74519e04)]);
        vk.gamma = Pairing.G2Point([uint256(0x0f8f9a4b5097401e835216456ddd34c5178f5051640433103dcbdbfed3599b52), uint256(0x126df1a0a820a454bfa1be659536e19a6be4057a4777915a5c3400e675e6f8a2)], [uint256(0x063a8977020d4ddb7fd2bba88dfaff04630f99b2e5283c7d76532d3cf02db653), uint256(0x23e20f37d13d78e41fe4ae3e851b240493b320f53f35fb9c18e31543c13d033b)]);
        vk.delta = Pairing.G2Point([uint256(0x2dac9e9cd023dd070dc7e1e8b471c0678ba60c26477902a3b66d805df003d12e), uint256(0x2d224a2d8d096faedd56563635937403177b6a658b23ccadf8b43b0f503592c8)], [uint256(0x14dea13a7bf30650b2354aebf4a04fa04b5a5e0f43d22fa4bd574a55d5a65085), uint256(0x1fcbfddf2a72131025af38fce69b70b4588cde4f33cd90e46d9c4f7b26767f33)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x0935c5cd691e108d6fa09335ab42af665d268695e6e42b922f9435c65b348cd7), uint256(0x22b94ed4c8470b50d514ed7c84054b4f4db54a1073bd9739b1a24d3e1fb9692e));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x0b50a7a0c8688f536dfde1ddc9c5ee88d20c5f4784b65ad167f8e743a8abcde2), uint256(0x100e2f9149cddd4b568df5e5a4a55c605dc3701ee3301d0d94004b2d7399339d));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x2bc9968724562c79b3b7457966ed6dcba33ff2289e322bf2d392c901c1393dd7), uint256(0x11e758a7061f525640a0df97336a820a715ff966942c2aa004e4dfae3c703b8e));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x27cac7c21422e458f973879defda668c6f67054c5bbd65272781a34b921059bf), uint256(0x0af7adc6fa3c442d4e339f58f6867ed6a171d487ccb60d6d40820674de28f082));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x19ac16ae801b9d57f21efba569a51885397e3490b2f95f2506132f07843f18ed), uint256(0x1e4e3f4ac69eaba00989ffbb956a21ef9dd5e19e36ad2634bac3f071b65fba9d));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x24f4ffdec94ed3e7e4aea98041eeda6f1cf233ec01aaf39c86335a4f8376914d), uint256(0x22eba0d66232090b29d479736ed97258766a1cb927932f0992cfa28524858d4f));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x2c36f72849c21b6ec60ea4846b70c9d86ab99361aef9603c2786a3397072ee3c), uint256(0x2314acf838f6abfd6aee591c93358acaf1d6bac6339245ae51bd453d8c8d6491));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x2fe04198cc80787a856a6fbc2d26641f9625c2002cb127bc4ffd0c64677865a9), uint256(0x2ac86b5ae461f78cd3ea082f096fd977df012d9c03cbc4593d13b9168cbad7cd));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x0a52c99556b83bfedb6d1b88eb3d53f934b9b9f3dedd31928afc4ee6eeded96c), uint256(0x25a046d211ef19c1b8899059cd7b6d6a6e728c155077168a7c57dcaf3be41318));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x038bed609efa3807f60f3782f7ca13327053c3d055d756f05fad77234984d9ae), uint256(0x1d3bb6a03c389f7bfc5716e983cd7d2f8c8bf20e431ee13d4e9e430cdf15c809));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x2c94a4c287bb209d573485e7fc1ba51949311595b88cebfc5ed4a69283045da7), uint256(0x0a1bdcbdef9fa523b65573b26e9d921491ba79ed412a3dd6f1a855a4034d28fb));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x02fea7a8711931e4ed25fc3bee9ea1bb23339dc3ebe2cd1eb5d89980ce1481c7), uint256(0x14ec6ee196b40aee962374453b19e16af4620417ae1e647ebee5f8ecf640dc58));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2874d74cf1ee877a6df6f281e4f8c90f008916c5004fa17d8ae923503d6f8a7b), uint256(0x0f46e1ac300eff6589bf65ded981124ef4092cc9b536e58989e58ee874752cc0));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x17da28be9038d7ecd2df8ff88614845201aac5fd92899095558ed75db9486b18), uint256(0x050342094a502de4acab1c65bf8240aa6a760ecc66c90a4163fe4fa864b5f1b9));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x040b766ddcfcd51381dffb598c065cd176650117a3b670ed086606fce5d3b92a), uint256(0x206a9481185a95dbbab0d02a81b3334f9e3e31ba7cfe1208a5d7225d8cdc3aba));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x0c29bfba78df3a553428a02900717a11944361a271696e85709c1a95c999286e), uint256(0x2e8744c3b7776216a6900b8a03c3dc104eb3a04a831aeec230f55ef4eb114421));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x2cd9de022c6c71991ebdc226782ec53ba90e539cb53b97f83d9e9ecd47f48876), uint256(0x0935ad77e69ddd80d7ba13c00a9a39d22dcaca90b8d40eee26e8633b3c5436cc));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x2b8df6482accdb3d650b6263d537bcd0be074baab8bea014f6fdf8534edd87df), uint256(0x05f5ee924c2deca0b81f74ca142705c291ff68986303e311a65c74b59cb3c754));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x174716f99c6add6c409dceb8f49a37fc700bb5211a8fd0322b2ddfe98fab4487), uint256(0x168bbccb05288490a1a29386cab0f639ba988b76e36c0399998c738f2401bb26));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2d7d74839b8650514cba2c66749d3f2f9055e141fb5a431f6c688dfcd4269b58), uint256(0x262f106c4d8f308cd850043958fd086d2f481c33a67025bfce5bb1b57a973458));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x020df9df4a2d8e1f1d72547e46a93f44d543604e571b185e7e882ef2d257d206), uint256(0x19d9c435437c1bef8a3fe34805b56a859f5bcf2d55f3fe4568b5937e52e8cac5));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x2a1aa37e60222bdc2698c46e39ade8f861690cb8f77258259d8ec95978157769), uint256(0x299e31061764739139037bbfd5f03836120ba68ebb57cc3bb411d9d46dc4f3b9));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x06f99e3ac9bb6275e874c9c65ec122babce6fe375d5cb56c4460cda207fd2816), uint256(0x26461ebe46e5a34254ea3c0afc898374bcd6e40dfe233d8a8c91f0bb14815374));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x221259213b12a5abcacfbc099c8d67df0b843a8385df9a2329a32df70b871e14), uint256(0x07ee76d5a9e74996e70b28649b5ffc8b4dc690817f637b6399a0c7c67edc3a5e));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x02c8b6b3e3c57b1692da33e8c8e16b251a06ff82e488782da2d752ef374b794e), uint256(0x107837e4c402bdcb0af60de5655149f6d074e58188d49baa5965de379aa557ff));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x022f520b1786648ed9b20567af8e0301d890270ef53a7abb394aa55de46b6b84), uint256(0x0990a5a4dc1d0aead918a3a53027d6dd96c2694b59a518306351ec0fab37d63f));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x2242d0b494b376b7e815ec015010a1615b9907f93f42b10213e14042bc88566d), uint256(0x21b8c6f7c5c2d775f4c22f26496b74e0bef6603323a3a023bccfccc18711dfd9));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x28b24011515a18ff1fd41c511f2e4552e654f445cd96d8a6768a4aa38b389355), uint256(0x031bff996f41a265ef0590db94ceab7e581c986a31f823860b431e436cbe53f4));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x04578b71b82e683ac7adca1aaafdc71511765f5dae2454b82133f79c09b8f0f1), uint256(0x1e93dcc0aff2f8d5ed883216d9fddddc4e35fdae305823678409a74b4873c8a8));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x2112632c57764eff042588eae446c9188702a8a65ad72c0bda850bd46416b881), uint256(0x0aeb0309f0c3c914b2d9373da1178a230a618d783401a61b5b51f441e7e23023));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x1c001b5a7ff0283c398838c4ad29a456e91ed78e73ff18533a9ce1b2129d40f2), uint256(0x0c6e9ee1a4bd4429455be8b92e7b77b696655215dd669694fef8cf1dcac6ad78));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x08c8deb29937722a75bae6d4d0a788edad9c8abf9409c9f611264028a08dd73e), uint256(0x080fdd396d0a4f73bfdd97cd00176d5c44729ada5fe2e372ab0765277180ae9b));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x224233dbbedf7768742f60d269312f618fa0f750a1cb73fc3269e8925bc7ec8a), uint256(0x092063819660e895a0a2aa50b2a694c022631985832c5ff6f5069a71662b556e));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x24fc65d6025bfad523e3cbada98409849115b34a0bd8f44f5787001c60693389), uint256(0x00513b18ae406739b511237c6f85153b9cea078a92296e53a5f066d1cdf2f82e));
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
