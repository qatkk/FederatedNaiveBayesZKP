const F1Field = require("ffjavascript").F1Field;
const utils = require("ffjavascript").utils;
const {subOrder, order, Base8, F, addPoint, mulPointEscalar, inSubgroup, inCurve, packPoint, unpackPoint} = require("circomlib/src/babyjub");
const crypto = require("crypto");
const assert = require('assert');

class BabyJubPoint {
    constructor(pointX, pointY) {
        if (pointX == null) {
            this.x = F.e("0");
        } else {
            this.x = F.e(pointX);
        }
        if (pointY == null) {
            this.y = F.e("1");
        } else {
            this.y = F.e(pointY);
        }
    }

    add(p) {
        if (!(p instanceof BabyJubPoint)) {
            assert(false, 'p should be a Point');
        }

        const q = addPoint([this.x, this.y], [p.x, p.y]);
        return new BabyJubPoint(q[0], q[1]);
    }

    sub(p) {
        if (!(p instanceof BabyJubPoint)) {
            assert(false, 'p should be a Point');
        }

        const q = addPoint([this.x, this.y], [F.neg(p.x), p.y]);
        return new BabyJubPoint(q[0], q[1]);
    }

    mul(e) {
        if (typeof e === 'bigint') {
            const q = mulPointEscalar([this.x, this.y], e);
            return new BabyJubPoint(q[0], q[1]);
        } else if (e instanceof Fr){
            const q = mulPointEscalar([this.x, this.y], e.n);
            return new BabyJubPoint(q[0], q[1]);
        } else {
            assert(false, "e should be BigInt or Fr")
        }
    }

    isInSubG() {
        return inSubgroup([this.x, this.y]);
    }

    isOnCurve() {
        return inCurve([this.x, this.y]);
    }

    compress() {
        return packPoint([this.x, this.y]);
    }

    decompress(b) {
        let p = unpackPoint(b);
        this.x = p[0];
        this.y = p[1];
        return [this.x, this.y];
    }

    equal(p) {
        if (!(p instanceof BabyJubPoint)) {
            assert(false, 'p should be a Point');
        }

        return (F.eq(p.x, this.x) && F.eq(p.y, this.y))
    }
}

exports.BabyJubPoint = BabyJubPoint;

exports.G = new BabyJubPoint(F.e("16540640123574156134436876038791482806971768689494387082833631921987005038935"),
                             F.e("20819045374670962167435360035096875258406992893633759881276124905556507972311"));

exports.subOrder = subOrder;
exports.order = order;
class Fr {
    constructor(n) {
        if (typeof n == "bigint"){
            this.Fr = new F1Field(subOrder);
            this.n = this.Fr.e(n);
        } else if (n instanceof Fr) {
            this.Fr = new F1Field(subOrder);
            this.n = n.n;
        } else if (n === null) {
            this.Fr = new F1Field(subOrder);
            this.n = this.Fr.e(bigint.zero);
        } else {
            assert(false, 'n should be a bigInt');
        }
    }

    add(a) {
        if (typeof a === 'bigint') {
            return new Fr(this.Fr.add(this.n, a));
        } else if (a instanceof Fr) {
            return new Fr(this.Fr.add(this.n, a.n));
        }
    }

    sub(a) {
        if (typeof a === 'bigint') {
            return new Fr(this.Fr.sub(this.n, a));
        } else if (a instanceof Fr) {
            return new Fr(this.Fr.sub(this.n, a.n));
        }
    }

    mul(a) {
        if (typeof a === 'bigint') {
            return new Fr(this.Fr.mul(this.n, a));
        } else if (a instanceof Fr) {
            return new Fr(this.Fr.mul(this.n, a.n));
        }
    }

    equal(a) {
        if (typeof a === 'bigint') {
            return this.Fr.eq(this.n, a);
        } else if (a instanceof Fr) {
            return this.Fr.eq(this.n, a.n);
        }
    }
}

exports.Fr = Fr

function randFr() {
    const buff = Buffer.from(crypto.randomBytes(32).toString('hex'));
    var init;
    while(true){
      init = new Fr(BigInt(utils.leBuff2int(buff)));
      if(init.n < BigInt(subOrder)){
        break;
      }
    }
    return init;
}
function keyGen(secret){
    let G = new BabyJubPoint(F.e("16540640123574156134436876038791482806971768689494387082833631921987005038935"),
                               F.e("20819045374670962167435360035096875258406992893633759881276124905556507972311"));
    if (typeof secret === 'bigint') {
        const secretValInField = new Fr(secret);
        const compressedPoint = G.mul(secretValInField.n);
        const compressedPointInt = utils.leBuff2int(compressedPoint.compress());
        return {'infield': secretValInField, 'Public_point': compressedPoint , 'Public_key': compressedPointInt};

    } else {
        assert(false, "Secret should be bigInt")
    }
}
function keyGenRand(){
    let G = new BabyJubPoint(F.e("16540640123574156134436876038791482806971768689494387082833631921987005038935"),
                                 F.e("20819045374670962167435360035096875258406992893633759881276124905556507972311"));
    const rand = utils.leBuff2int(crypto.randomBytes(32));
    const buffToBigint = BigInt(rand);
    const randomValInField = new Fr(buffToBigint);
    const keyPointOnCurve = G.mul(randomValInField);
    const compressedPoint = new BabyJubPoint(keyPointOnCurve.x, keyPointOnCurve.y);
    //const Compressed_point_int = Compressed_point.compress();
    const compressedPointInt = utils.leBuff2int(compressedPoint.compress());
    return {'Secret': buffToBigint , 'Public_point': keyPointOnCurve , 'Public_key': compressedPointInt , 'Secret_in_field': randomValInField.n};
}
exports.keyGen = keyGen;
exports.keyGenRand = keyGenRand;
exports.randFr = randFr;
