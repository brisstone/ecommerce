class Customer{
  String i;//customer id
  String e;//customer email
  String p;//customer phone number
  String a;//customer address
  String w;//wallet amount
  String f;//first name
  String l;//sur / last name
  String s;//customer state --Index of state
  String t;//status of customer: is seller or not.
  String q;// Password
  String cid;// Cart item ids

  Customer();

  Customer.fromMap(dynamic value) {
    if(value==null || value.toString().trim()=='null') return;
    this.i = value.containsKey('i')?value['i'].toString():'';
    this.e = value.containsKey('e')?value['e'].toString():'';
    this.p = value.containsKey('p')?value['p'].toString():'';
    this. a = value.containsKey('a')?value['a'].toString():'';
    this. w = value.containsKey('w')?value['w'].toString():'';
    this. f = value.containsKey('f')?value['f'].toString():'';
    this.l = value.containsKey('l')? value['l'].toString():'';
    this.s = value.containsKey('s')?value['s'].toString():'';
    this.t = value.containsKey('t')? value['t'].toString():'';
    this.q = value.containsKey('q')? value['q'].toString():'';
    this.cid = value.containsKey('cid')? value['cid'].toString():'';
    print('From inside: ${value['i']}');
    print('From inside: ${value['e']}');
    print('From inside: ${value['a']}');
    print('From inside: ${value['p']}');
    print('From inside: ${value['w']}');
    print('From inside: ${value['l']}');
    print('From inside: ${value['s']}');
    print('From inside: ${value['t']}');
    print('From inside: ${value['cid']}');
  }

  toMap() {
    return {
      'i': i,
      'e':e,
      'p':p,
      'a':a,
      'w':w,
      'f':f,
      'l':l,
      's':s,
      't':t,
      'cid':cid,
      'q':q??''
    };
  }

  @override
  String toString() {
    return('customer id: $i,  email: $e, phone number: $p, address: $a, cart ids: $cid, wallet amount: $w, first name: $f, last name: $l, state:$s, status: $t');
  } //state


}