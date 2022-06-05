import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:irrigation_app/core/context/tb_context.dart';
import 'package:irrigation_app/core/context/tb_context_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class FarmerActivationView extends TbPageWidget {
  final String userId;

  FarmerActivationView(TbContext tbContext, {Key? key, required this.userId})
      : super(tbContext, key: key);

  @override
  _FarmerActivationView createState() => _FarmerActivationView(userId);
}

class _FarmerActivationView extends TbPageState<FarmerActivationView> {
  late String userId;
  late Future<String> link;
  static late  Uri _url;
  _FarmerActivationView(this.userId);

  @override
  void initState() {
    super.initState();
    link = _getUserActivationLink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Farmer activation'),
        ),
        body: FutureBuilder<String>(
            future: link,
            builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
              if (snapshot.hasData) {
                String link = snapshot.data;
                _url = Uri.parse(link);
                return ListView(
                  padding: EdgeInsets.all(20),
                  children: [
                    showDetails('Activation link: ', link),
                  ],
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text('Loading...'),
                      )
                    ],
                  ),
                );
              }
            }));
  }

  Future<String> _getUserActivationLink() async {
    final link = await tbClient.getUserService().getActivationLink(userId);
    return link;
  }

  static Widget showDetails(String column1, String column2) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Flexible(
              child: Text(
                column1,
                style:
                    const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: InkWell(
                  child: Text(column2),
                  onTap: () {
                    _launchUrl();
                  }),
            ),
          ],
        ),
      ),
    );
  }

  static void _launchUrl() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }
}
