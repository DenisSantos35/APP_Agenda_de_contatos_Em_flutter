import 'dart:io';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:agenda_contatos/iu/contact_page.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

enum OrderOptions{orderaz, orderza}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //precisamos importar a nossa contactHelper para este arquivo
  //e instanciamos em helper, no nosso código so podemos utilizar uma unica instancia, as demais criadas sera apenas uma copia
  ContactHelper helper = ContactHelper();

//vamos fazer um teste no nosso bancco de dados
  //no initState passamos sup init state
  //e manipulamos nosso banco
  /* @override
  void initState() {
    super.initState();
    //primeiro instanciamos um objeto
    //e atribuimos os valores para serem salvos atraves do objeto criado
    Contact pessoa1 = Contact();
    pessoa1.name = "Luiz ";
    pessoa1.email = "luiz@hotmail.com";
    pessoa1.phone = "16000000000";
    pessoa1.img = "testimg3";

    //Apartir da nossa instancia podemos salvar o nosso contato
    helper.saveContact(pessoa1);*/ /*

    //para ler todos os contatos como e retornado um valor no futuro ou damos um await
    //ou retornamos uma then
    helper.deleteContact(2);
   helper.getAllContacts().then((value) => print(value));

   helper.getContact(3).then((value) => print(value));

  }*/
  //cria uma lista da classe de contatos
  List<Contact> contacts = [];

  //quando iniciar carregar os contatos salvos utilizamos o intitState
  @override
  void initState() {
    super.initState();
   _getAllContacts();
  } //carregar todos os contatos salvos

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90,
        title: const Text("Contatos"),
        backgroundColor: Colors.red,
        centerTitle: true,
        actions: [
          PopupMenuButton<OrderOptions>(itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
            const PopupMenuItem<OrderOptions>(
                child:Text("Ordenar de A-Z"),
              value: OrderOptions.orderaz,
            ),
            const PopupMenuItem<OrderOptions>(
              child:Text("Ordenar de Z-A"),
              value: OrderOptions.orderza,
            ),
          ],
            onSelected: _orderList,

          )
        ],
      ),
      //botao flutuante
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: const Icon(
          Icons.add,
        ),
        backgroundColor: Colors.red,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        //especificar o tamanho da lista
        itemCount: contacts.length,
        //passar a funcao que vai retornar o item da posição
        itemBuilder: (context, index) {
          return _contactCard(context, index);
        },
      ),
    );
  }

  //***********************criacao de widget atraves de funcao **************

  Widget _contactCard(BuildContext context, int index) {
    //para conseguir capturar os movimentos no card colocamos gestureDetector
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              //para fazer imagem redonda coloque um container, especifica a largura e a altura
              //definir uma decoração boxdecoration, o formato precisa ser um shape: boxShape circle
              //e na imagem colocar uma imagem de decoração
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: contacts[index].img == null ?DecorationImage(
                    image: AssetImage("image/person.png"),
                    fit: BoxFit.cover
                  ): DecorationImage(image: FileImage(File(contacts[index].img!)),
                  fit: BoxFit.cover),
                ),
              ),
              Padding(
                  padding: EdgeInsets.only(left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(contacts[index].name ?? "",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(contacts[index].email ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(contacts[index].phone ?? "",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: (){
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index){
    showModalBottomSheet(
        context: context,
        builder: (context){
          return BottomSheet(
              onClosing: (){},
              builder: (context){
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(onPressed: (){
                          launchUrl(Uri.parse("tel: ${contacts[index].phone!}"));
                          Navigator.pop(context);
                        },
                            child: Text("Ligar", style: TextStyle(color: Colors.red, fontSize: 20),),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(onPressed: (){
                          Navigator.pop(context);
                          _showContactPage(contact: contacts[index]);
                        },
                          child: Text("Editar", style: TextStyle(color: Colors.red, fontSize: 20),),),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: TextButton(
                          onPressed: (){
                          helper.deleteContact(contacts[index].id!);
                          setState(() {
                            contacts.removeAt(index);
                            Navigator.pop(context);
                          });

                        },
                          child: Text("Excluir", style: TextStyle(color: Colors.red, fontSize: 20),),),
                      ),

                    ],
                  ),
                );
              }
          );
        });
  }

  void _showContactPage({Contact? contact}) async{
    final recContact =  await Navigator.push(context,
    MaterialPageRoute(builder: (context) => ContactPage(contact: contact,))
    );
    if(recContact != null){
      if(contact != null){
        await helper.updateContact(recContact);
      }else{
        await helper.saveContact(recContact);
      }
      _getAllContacts();

    }
  }

  void _getAllContacts(){
    helper.getAllContacts().then((list){
      setState(() {
        contacts = list as List<Contact>;
      });
    });
  }

  void _orderList(OrderOptions result){
    switch(result){
      case OrderOptions.orderaz:
        setState(() {
          contacts.sort((a, b) {return a.name!.toLowerCase().compareTo(b.name!.toLowerCase());});
        });
        break;
      case OrderOptions.orderza:
        setState(() {
          contacts.sort((a, b) {return b.name!.toLowerCase().compareTo(a.name!.toLowerCase());});
        });
        break;
    }


  }


}
