class ShopData{

  String l;// shop id
  String e;// shop details


  ShopData.withDetails(this.l, this.e);

  Map<String, String> toMap(){
    return {
      'l':l,
      'e':e
    };
  }

  ShopData.fromMap(var map) {
    this.l=map['l'];
    this.e=map['e'];
  }
}