import 'package:sqflite/sqflite.dart'; // classe para o bd
import 'package:path/path.dart';
import 'dart:async';
//declarar os nomes que serão utilizados nas colunas
//podemos declarar final pois essas strings nao irao mudar

//este vai ser o nome da tabela, foi declarado para garantir que nao vamos errar o nome
final String contactTable = "contactTable";

final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

//nesta classe vamos ter apenas um objeto para todas as classe
class ContactHelper{ //aqui quando instanciamos o objeto pode se instanciar quantos quiser tera sempre o mesmo valor
  //iniciamos com  static para definir que o metodo e da classe e nao do objeto
  //declaramos final para falar que ela e unica e nao vai ser alterada
  static final ContactHelper _instance = ContactHelper.internal(); //aqui cria um objeto da classe contendo so esta instancia

  factory ContactHelper() => _instance; //para obter o objeto de qualquer lugar
                                        //e necessário chmar ContactHelp._instance
  ContactHelper.internal();//Este contrutor so pode ser chamado daqui de dentro

//agora declara o banco de dados
  Database? _db;

  //inicializando banco de dados
  //caso queira pegar o banco de dados dar um ponto db
  Future<Database> get db async{
    if(_db != null){ //caso o banco ja esteja inicializado retornamos o _db
      return _db!;
    }else{
      _db = await initDb(); //caso nao esteja inicilazado e preciso inicilizar chamando a funcao initDb()
      return _db!;
    }
  }

  //funcao para inicialização do banco de dados
  Future<Database> initDb() async{
    //primeiro precisamos pegar onde o banco de dados esta armazenado
    //com comando
    final databasesPath = await getDatabasesPath(); //pegando local ele demora a resposta por isso await
    final path = join(databasesPath, "contactsnew.db"); //aqui estou juntando o caminho do banco de dados com o nome do banco

    //procimo passo agora ja com o caminho e necessário para abrir o banco de dados
    //assim usamos openDataBase(caminho=path, versao: (nocaso 1), criar(passa uma funcao com 2 parametros)
    //ESTA FUNCAO SERA CRIADA APENAS UMA VEZ
    //retornamos aqui a abertura do banco de dados passando comandos para criacão do database criando uma tabela
    return await openDatabase(path, version: 1, onCreate: (Database db, int newerVersion) async{
      await db.execute(
        //comandos do bd colocar em maiusculas e parametros letras minusculas
        //COMANDO PARA CRIACAO DA TABELA.
        //cria tabela com nome contactetable e dentro dos parenteses o nome das colunas
        "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn  TEXT,"
            "$phoneColumn TEXT, $imgColumn TEXT)"
      );
    });
  }

  //para salvar itens no banco de dados criamos uma funcao saveContact
  //passamos parametro como Contact contact
  //como demora e uma funcao asyncrona
  Future<Contact> saveContact(Contact contact) async{
    //passamos uma variavel com parametro Database que vai receber dado do nosso banco de dados
    Database dbContact = await db;
    contact.id = await dbContact.insert(contactTable, contact.toMap()); //inserir o contato na tabela aqui fazemos salvamento
                                                                        //em um mapa estamos pegano os valores passado para o banco
                                                                        //que esta armazenado em dbContact
                                                                        //e inserindo na tabela contato os valores
                                                                        //para cada coluna ja criada o seu valor
                                                          //contact.toMap esta acessando o metodo que cria mapas e retorna no final
                                                          //o id, assim com contact.id estamos atribuindo o id gerado para a coluna id
                                                                        //e por fim retornar o mapa gerado
    //obter o id e retornar
    return contact; //aqui estamos retornando o objeto
  }

  //para pegar o objeto ao qual esta armazenado vamos fazer uma funcao
  //futura contact ela recebera o id que foi armazenado no salvamento
  Future<Contact?> getContact(int id)async{
    //primeiro obter o banco de dados
    Database dbContact = await db;
    //retornaremos uma lista de mapas onde chamaremos de mapas
    //daremos uma query solicitando os dados na posição solicitada
    //nesta query vamos passar o nome da tabela, as colunas, e a regra para obter o contato
    //a regra sera onde o idColumn for igual a onde o argumento seja igual ao id
    List<Map> maps = await dbContact.query(contactTable,
    columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
    where: "$idColumn = ?",
    whereArgs: [id]);
    if(maps.length > 0){
      return Contact.fromMap(maps.first);
    }else{
      return null;
    }
  }
  //aqui vamos fazer um metodo para deletar dados de dentro do banco de dados
  //nela criamos uma função que recebera a chave primaria id
  Future<int> deleteContact(int id) async{
    //no corpo acessamos o banco de dados
    Database dbContact = await db;
    //de dentro do banco passamos que queremos deletar, da tabela de contatos,
    // onde o idcolumn e igual onde o argumento e igual ao id passado
    //por se tratar de banco precisamos esperar assim passamos um await
    //e reternomos este banco de dados atualizado com o item ja deletado
    //delete retorna um numero inteiro falando se deu certo ou nao
    return await dbContact.delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  //metodo para atualizar o contato inciamos criando uma funcao update
  //e passamos como parametro o mapa da nossa classe de contato
  Future<int>updateContact(Contact contact) async{
    //acessamos nossa base de dados bassando para uma variavel
    Database dbContact = await db;
    //passamos a seguinte funcao para nossa base de dados
    //da base de dados atualiza, da tabela de contatos, o mapa de contatos
    // onde a coluna de id tem como argumento o id especifico passado
    //o update retorna um numero inteiro falando se deu certo ou nao
    return await dbContact.update(contactTable, contact.toMap(), where: "$idColumn = ?", whereArgs: [contact.id]);
  }

  //agora vamos criar uma funcao para obter todos os dados de uma só vez
  Future<List>getAllContacts() async{
    //vamos obter o banco de dados criado
    Database dbContact = await db;
    //Criamos uma lista para armazenar todos os contatos
    //chamamos nosso banco e damos uma rawQuery , selecionando todos os dados REPRESENTADO POR(*) ASTErISTICO, da tabela do bd
    List listMap = await dbContact.rawQuery("SELECT * FROM $contactTable");
    //nao queremos retornar uma lista de mapas assim criamos uma nova lista para transformar estes dados
    //abaixo criamos uma lista da classe Contact com nome listContact e inicializamos com umalista vazia
    List<Contact> listContact = [];
    //fazemos uma iteracao onde o m vai receber cada mapa gerado na list map
    //e vamos adicionar a nova lista agora transformano de mapa para lista
    for(Map m in listMap){
      listContact.add(Contact.fromMap(m));
    }
    //apos todos os dados adicoinados retornamos esta lista
    return listContact;
  }

  //vamos criar agora uma funcao para obter o numero de contatos da nossa lista
  Future<int?> getNumber() async{
    //primeiro obter o banco de dados
    Database dbContact = await db;
    //chamamos o metos sqflite e fazemos uma contagem de itens para saber quantos cadastros temsos
    //no nosso banco de dados na tabela de contatos
    return Sqflite.firstIntValue(await dbContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  //Agora vamos fechar nosso banco de dados
  //criamos uma função close
  Future close() async{
    Database dbContact = await db;
    dbContact.close();
  }

}




// ************** classe que cria o mapa e extrai o mapa **********************
class Contact{
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;
  Contact();
//construtor para criar um map dos itens que estamos cadastrando e armazenar no BD
  //atribui para as variaveis em forma de mapa as colunas que foram criadas
  //Aqui estamos pegando os dados e transformando em mapa
  Contact.fromMap(Map map){
    id = map[idColumn];
    name = map[nameColumn];
    email = map[emailColumn];
    phone = map[phoneColumn];
    img  = map[imgColumn];
  }
  //agora vamos criar um metodo que vai transformar os mapas em dados
  //tera um map onde a string sera o nome da coluna e o dynamic a o valor
  Map<String,dynamic> toMap(){
    Map<String, dynamic> map = {
      nameColumn: name,
      emailColumn: email,
      phoneColumn: phone,
      imgColumn: img,
    };
    if(id != null){
      map[idColumn] = id;
    }

    return map;
  }

  //aqui estamos modificando em to string e recebendo os valores ao inves do parametro to string
  @override
  String toString() {
    return "Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)";
  }
}