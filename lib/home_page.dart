import 'package:flutter/material.dart';
import 'package:project_app/api.dart';
import 'package:project_app/response_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  ResponseModel? responseModel;
  String noDataText = "Welcome, to our Dictionary!";

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: SafeArea(
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildHeaderWidget(),
                const SizedBox(height: 12),
                if (inProgress)
                  const LinearProgressIndicator()
                else if (responseModel != null)
                  Expanded(child: _buildResponseWidget())
                else
                  _noDataWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book,
                color: Colors.black87,
                size: 30,
              ),
              SizedBox(width: 8),
              Text(
                "Dictionary",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                ),
              ),
            ],
          ),
        ),
        _buildSearchWidget(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildResponseWidget() {
    return Container(
      width: double.infinity,
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              responseModel!.word!,
              style: TextStyle(
                color: Colors.purple.shade600,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(responseModel!.phonetic ?? ""),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  return _buildMeaningWidget(responseModel!.meanings![index]);
                },
                itemCount: responseModel!.meanings!.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeaningWidget(Meanings meanings) {
    String definitionList = "";
    meanings.definitions?.forEach(
          (element) {
        int index = meanings.definitions!.indexOf(element);
        definitionList += "\n${index + 1}. ${element.definition}\n";
      },
    );

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            meanings.partOfSpeech!,
            style: TextStyle(
              color: Colors.orange.shade600,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Definitions : ",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(definitionList.trim()),
          _buildSet("Synonyms", meanings.synonyms),
          _buildSet("Antonyms", meanings.antonyms),
        ],
      ),
    );
  }

  Widget _buildSet(String title, List<String>? setList) {
    if (setList?.isNotEmpty ?? false) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$title : ",
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(setList!.join(', ')),
          const SizedBox(height: 10),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _noDataWidget() {
    return SizedBox(
      height: 100,
      child: Center(
        child: Text(
          noDataText,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  Widget _buildSearchWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Type here the word you want to know about",
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          _getMeaningFromApi(value);
        },
      ),
    );
  }

  void _getMeaningFromApi(String word) async {
    setState(() {
      inProgress = true;
    });
    try {
      responseModel = await API.fetchMeaning(word);
      setState(() {});
    } catch (e) {
      responseModel = null;
      noDataText = "Meaning cannot be fetched";
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
