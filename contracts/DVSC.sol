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
        vk.alpha = Pairing.G1Point(uint256(0x2a63d23b73c06cb185f8d617ed33ad8daf0db004855df5cc82b3692252ad2c67), uint256(0x0073781c2b2844f8085a11f5f39adebdc629ec9abd6f211e3c8951231ae49260));
        vk.beta = Pairing.G2Point([uint256(0x1dd2eca2478eb684b7f42b5b8cc53eb24b98f40b42a20fa10f0e41045028230e), uint256(0x1915be54b6575eb81115c81e7b3cf5daa922865167ad1a6ba7d2637bd3e40783)], [uint256(0x2135b30dd846e6408fd4ece3ee713fa287eba621dc3bcf421b85c996edc106d6), uint256(0x0ba4e5b6b1a87cd644aee2c9e9d3d2e1c4fb8dd0d45d5ab60732a4bebd4e3690)]);
        vk.gamma = Pairing.G2Point([uint256(0x27b28f604ff94891ea99a5deecdbd53eff7d2601ae7dfa4c95bf5a3565e0bb99), uint256(0x2b11b8ba434b191238c07cda3e96eb732aa5ccb9258bfd08497f75ac41489041)], [uint256(0x02afe96e9def68cc5e167f2aaff8943aed7a1bb4b393ac094792a9215df50b2d), uint256(0x0a64e5e37ed6f982833722ec4ea8f2da6bfcc0a2ba9d51c566d8b0ad5221727f)]);
        vk.delta = Pairing.G2Point([uint256(0x1d67cc90eb20d8ebe3e6c0b9edc307a1176b1f89dc846b84e067cac2e6ae375d), uint256(0x29b194f7451933b938157f0c3a495e57ba10a0042e6452ca8b09441441543689)], [uint256(0x0dad938f2366792f6a4a17310b992076c0bf350c1a5c961721eb58e683ff5807), uint256(0x1b00f1ffbff7a21a69ff52007686fc23f5fed44f6ef857f5fab2146f6d1b56b7)]);
        vk.gamma_abc = new Pairing.G1Point[](34);
        vk.gamma_abc[0] = Pairing.G1Point(uint256(0x1050789e17da5095992ce0fa14c3d9606e3250302f435c870f27e80fc4016fe8), uint256(0x2900a5c597acd2efcd676a8092beb851f28d9042eec9d34b467db0c43a83fa1b));
        vk.gamma_abc[1] = Pairing.G1Point(uint256(0x23b85222953afca2e33feff9d8b608c82c47259761229254f8666a46c9e36ccd), uint256(0x2915da4eabc247ce5dd5f2746e0d9f120343ca573c90a2a9b4f47cbe29db80d1));
        vk.gamma_abc[2] = Pairing.G1Point(uint256(0x087325d135f7165b54c79ec0200d14becb1f8641a473c9f8e3ecdf0793990241), uint256(0x16eb1ff598f6c3a0576c99479046ec3d1efb9b248c7b78878e5543ca1433609b));
        vk.gamma_abc[3] = Pairing.G1Point(uint256(0x05cffb5652773375c6c5b324e2a18afce7079813bd53d75108a39962d6f67ecc), uint256(0x09d545d82f962db8f2752ee96832974a1b533a6f8f494c41f61782d80becefdc));
        vk.gamma_abc[4] = Pairing.G1Point(uint256(0x2922a00cc8962a4e57b58cfe4e8bd1f1fefa8eb2b554d86e11847da205dd2f33), uint256(0x18bce3ed9ef21c85c49bae7ed20e5522a1312275c262b68dd854b84cf8a3f508));
        vk.gamma_abc[5] = Pairing.G1Point(uint256(0x264c152c47a0a94c583cc57bfe59f164ede5673d51b3eb8cf226bdd336ee354e), uint256(0x0e3511ba0b9aa6565c7faded32e2f2dbee74844c886c8a3bea8e8e87c2626835));
        vk.gamma_abc[6] = Pairing.G1Point(uint256(0x153ecefd7044de6637e8485c6580109d54690e26303dbce2cf47eea1e9b531a0), uint256(0x088a78674503f8d575fb5e83a85ea3eed0fa278b210d001116feea2caac274f1));
        vk.gamma_abc[7] = Pairing.G1Point(uint256(0x0f5d3f192f4af7a753ea3f799b560a5828ed21d10ea3b446186f11ec984c6d4c), uint256(0x2f053344241a55e0155098f93f518d3456cd6e8920cd04fd1002b3bb80dced9c));
        vk.gamma_abc[8] = Pairing.G1Point(uint256(0x248b8ed7ab6976340153a956808103cd5b97cf5cf3b445a38c9e13de773f0133), uint256(0x05f73a367ac56770a0ca8ed9268e8b11acaa2e39c3db6333c597bb21e9ac7d4c));
        vk.gamma_abc[9] = Pairing.G1Point(uint256(0x100edea5a4595eb09b8cd5f4206354acc297bb203900ed4fe0a32046a73a508c), uint256(0x024c29ae50bd0c941dfba7fe9bcf2d97e593ec84195852f3beb689fd9873fd62));
        vk.gamma_abc[10] = Pairing.G1Point(uint256(0x0c142a6ee4666975adf5ea2c787927fc281084ff88698ab17e2a74d34f73d5df), uint256(0x2283c79c85cac4359e7689a3094fb367f7a9b2ce1ffa1d9047af1159b220a5fb));
        vk.gamma_abc[11] = Pairing.G1Point(uint256(0x05b8c3057af41a9331497bbc05a03925bf9d653127c53e50e9662fda45a73aa4), uint256(0x0490dfcc2e3c792c2cedfed3245b203a349dc3311780547e87b476250b589a8e));
        vk.gamma_abc[12] = Pairing.G1Point(uint256(0x2ede49217193cf92b82ed61b8abfb6ad1485481c2a21019aece206603d474278), uint256(0x28336d9709e72acd818153fc1225ec204d2b7a756b1a73760532727f36e25c50));
        vk.gamma_abc[13] = Pairing.G1Point(uint256(0x02dee14024f2c8d9a6cd34d82d74418d582434a75069430745fdaf238139cb49), uint256(0x0eb3512f56ae89d88fb72e4c7c3492c43f75dbfa56c1f037b8abc546e735c3bc));
        vk.gamma_abc[14] = Pairing.G1Point(uint256(0x06165aa373ab626f5926f07e09587f4a2632ea7b5cf1edafd8a07e91d40fe2b3), uint256(0x2a9baac92791e6e4a676dda2ab0990f6a7234e67c0fa11a0cd0c4e76be724a15));
        vk.gamma_abc[15] = Pairing.G1Point(uint256(0x097c1c400d1e82ad8bb62deaba0893f205c7bf815862bc12bdb00223ef5ab3eb), uint256(0x1f03bd81e810b991c095fcd822d54cd07ae45d01c32fc02b515331f685c3cceb));
        vk.gamma_abc[16] = Pairing.G1Point(uint256(0x290d04fff212f268cc6544d8d60d452233ef7118519ac7e81879d8278a8039c5), uint256(0x133d49b4ff993040bf66e0d7958b2cb4b6dae64065083f7fe606fe338d881478));
        vk.gamma_abc[17] = Pairing.G1Point(uint256(0x19d983664c236935647037c94fbdee36f5aeb9adcc5a4ce4fb40fbf212fb8575), uint256(0x180d54c8a3d5ec0fa6e30a6108f14089be48828079fe10f6872b72c8c4c7faf8));
        vk.gamma_abc[18] = Pairing.G1Point(uint256(0x1d8b2085f333c7dbc6e5d2bbd2bce114e6e5108aaac4059cc536e7ec5bf7ef74), uint256(0x1356c793e2e6794fa5e9a780893177bf39a38ac53eacc5adf526ed11944a77f3));
        vk.gamma_abc[19] = Pairing.G1Point(uint256(0x2d403f8bf3d04339662098f3bd249b4d527aadffa48b91017cc2e612a5f9cbde), uint256(0x21ff7d19716f78004e0dee01def1b4280df7f1687b7ff689e27a1474e53b6e26));
        vk.gamma_abc[20] = Pairing.G1Point(uint256(0x1a21a1c67fac300309783a5e6e901a23bca77967892099a11ab97c2af82cd152), uint256(0x06871456744cbc9d0ccee1e0eaf32910b827e7d5ea752fab4035696248fb9f7c));
        vk.gamma_abc[21] = Pairing.G1Point(uint256(0x18d6f0a06e2e51a63b1a1f6e3c1322cf6733ee7b71a97b1710902fe11009fa62), uint256(0x067223512f6a145c9b1b3e9477a86c3b919af782e82062304a25eba2198e5425));
        vk.gamma_abc[22] = Pairing.G1Point(uint256(0x281e5a721a7b2089ded6f571bbfd626b43a7a89c13e43c31016a77c255fd9ceb), uint256(0x12ac41adc09f8b58e070d11427443579b1130dbabe7b917bf4233ca04be1e2cb));
        vk.gamma_abc[23] = Pairing.G1Point(uint256(0x09927a93362a656a1edf6eb9ab3e2d0aaad1739d963bc6006d29faddf2319c30), uint256(0x05f711159f8ec77cae2a7024b3a0c87c60a729b6e500e7a9062a4d7f1900ffda));
        vk.gamma_abc[24] = Pairing.G1Point(uint256(0x0d3a3aa4939c54d4a2969b82d7fe887292abbbf97c8cacf11ef627af26f55249), uint256(0x015d52ea4de2aab02c1b368b39ce4a29e22be80ee5303d255336abc943075daf));
        vk.gamma_abc[25] = Pairing.G1Point(uint256(0x23720766db07869b28a9e56828fe077a44823cfcf38c7f2067c9cbe0bbf8a2e3), uint256(0x1fa3617ceda16f3430c5eac9dc0a0804b76de5ddd13b18eb363f8b79970f2488));
        vk.gamma_abc[26] = Pairing.G1Point(uint256(0x0339fd49153de4b518c81f41c9d3b6e26f7fb5c04376809aa73cf136d0b31d63), uint256(0x057eda5fe20151b9c2968d88caadb95ae55fa08e4e08cea60af3daf50b2eaba0));
        vk.gamma_abc[27] = Pairing.G1Point(uint256(0x2f21fa3bf197c3c5705992014d735584b103d2f1afc16e59909dd219e0dd2658), uint256(0x10ef793ea0cf315ce09413fceb535e456c53226bbd1517ff56f6d15642305486));
        vk.gamma_abc[28] = Pairing.G1Point(uint256(0x284e354e590341d41ab0dce79c54d0893264de6dfbf0bc55f5a8aa93334b3b7a), uint256(0x054881b94faf9c2922a2b2e03172ac3aa6be6330611c841cc7d7951a745c3cab));
        vk.gamma_abc[29] = Pairing.G1Point(uint256(0x227333b130805633fcf82b73ce18c252a331a1a276af73821e609a93d2cd6eea), uint256(0x066e1e65b26b67cd60dc737d00613d91e4d3467d463186c9eac4f92dcaeba9b3));
        vk.gamma_abc[30] = Pairing.G1Point(uint256(0x0f6de914601575b0ce472c583a73af6df2af9e6691f07f511030e97966d1174e), uint256(0x279a582c4af9ad3e426c5337b2c3d53641199c757528f41102d20235ecbca2f4));
        vk.gamma_abc[31] = Pairing.G1Point(uint256(0x03df20cace11d046cc9ce0155659e0c2d7fbfd52f208def0858d26ab257438d9), uint256(0x1b80cea26b93b76a613a181755c9290fd9bd421c3c30ab61500c8cc34b5cf5b9));
        vk.gamma_abc[32] = Pairing.G1Point(uint256(0x1052f5eaf9664b45b32f7d026b2451d9eec6235d057a128ab61a156a0ec726ed), uint256(0x2edd3531e416acbf922e8a7f8c5f766aacdc8cd437caff568bf11c65c9360875));
        vk.gamma_abc[33] = Pairing.G1Point(uint256(0x1d7b1bbe68b78bb941bc429f4e26b99255ba58b20ddb9b5bc3412897d89a0740), uint256(0x0a9cf1ac405aef37867b3d0e4efe733fae8afde0b9bc4be1fca31e5283a2deba));
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
