import 'dart:io';
import 'package:flutter/material.dart';
import 'package:agenda_contatos/helpers/contact_helper.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  //ao criar a pagina que ira receber os dados criamos um construtor
  //que ira receber a lista de contatos que serao editados na pagina
  //passamos compo parametro opcional olocando entre chaves
  final Contact? contact;

  ContactPage({this.contact}); //construtor

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _nameControler = TextEditingController();
  final _emailControler = TextEditingController();
  final _phoneControler = TextEditingController();

  final _nameFocus = FocusNode();

  bool _userEdited = false;
  Contact? _editedContact;

  @override
  void initState() {
    super.initState();
    //toda vez que iniciar a página
    //vamos buscar a lista de contatos e fazer a verificação
    //para acessar usamos o widget.contacts, onde o widget acessa o widget
    if (widget.contact == null) {
      //ao iniciar o app ela vai buscar a lista de ontatos
      _editedContact = Contact();
    } else {
      //aqui estou pegando o contato da minha pagina e transformando em um mapa
      //e passando para a pagina construir esse novo contato
      _editedContact = Contact.fromMap(widget.contact!.toMap());
      _nameControler.text =
          _editedContact!.name == null ? "" : _editedContact!.name!;
      _emailControler.text =
          _editedContact!.email == null ? "" : _editedContact!.email!;
      _phoneControler.text =
          _editedContact!.phone == null ? "" : _editedContact!.phone!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop, // chama a funcao
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 90,
          centerTitle: true,
          backgroundColor: Colors.red,
          title: Text(_editedContact!.name ?? "novo Contato"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (_editedContact!.name!.isNotEmpty &&
                _editedContact!.name != null) {
              Navigator.pop(context, _editedContact);
            } else {
              FocusScope.of(context).requestFocus(_nameFocus);
            }
          },
          child: Icon(Icons.save),
          backgroundColor: Colors.red,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _editedContact!.img != null
                            ? FileImage(File(_editedContact!.img!))
                            : AssetImage("image/person.png")
                                as ImageProvider<Object>, fit: BoxFit.cover),
                  ),
                ),
                onTap: ()async{
                  ImagePicker().pickImage(source: ImageSource.gallery).then((file) {
                    if(file == null){
                      return;
                    }
                    setState(() {
                      _editedContact!.img = file.path;
                    });
                  });
                },
              ),
              TextField(
                controller: _nameControler,
                focusNode: _nameFocus,
                decoration: InputDecoration(
                  labelText: "nome",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  setState(() {
                    _editedContact!.name = text;
                  });
                },
              ),
              TextField(
                controller: _emailControler,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "e-Mail",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.email = text;
                },
              ),
              TextField(
                controller: _phoneControler,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Telefone",
                ),
                onChanged: (text) {
                  _userEdited = true;
                  _editedContact!.phone = text;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop(){
        if(_userEdited){
          showDialog(context: context, builder: (context){
            return AlertDialog(
              title: Text("Descartar alterações"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: [
                TextButton(onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Cancelar"),),
                TextButton(onPressed: (){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }, child: Text("Sim"),),
              ],
            );
          });
          return Future.value(false);
        } else{
          return Future.value(true);
        }
  }

}
