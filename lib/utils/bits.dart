int bitsToInt(List<bool> bools) {
  int result = 0;
  for (int i = 0; i < bools.length; i++) {
    result = (result << 1) | (bools[i] ? 1 : 0);
  }
  return result;
}

List<bool> intToBits(int number, {int bitLength = 32}) {
  List<bool> bools = [];
  for (int i = bitLength - 1; i >= 0; i--) {
    bool bit = (number >> i) & 1 == 1;
    bools.add(bit);
  }
  return bools;
}
