#include <kytea/kytea.h>
#include <kytea/string-util.h>
#include <vector>
#include <string>
#include <cstring>
#include <cstdlib>

#include <iostream>

#ifdef __cplusplus
extern "C" {
#endif

// g++ -shared -fPIC -o libkytea_wrap.so kytea_wrap.cpp

struct tag {
  char *name;
  double score;
};

struct word {
  char *surface;
  struct tag **tags;
};


kytea::Kytea* kytea_wrap_new(int argc, const char** argv) {
  try {
    kytea::KyteaConfig *config = new kytea::KyteaConfig();
    config->setOnTraining(false);
    config->parseRunCommandLine(argc, argv);

    kytea::Kytea *kytea = new kytea::Kytea(config);
    kytea->readModel(config->getModelFile().c_str());
    return kytea;
  } catch (...) {
    return nullptr;
  }
}

void kytea_wrap_destory(kytea::Kytea* kytea) {
  delete kytea;
}


char** kytea_wrap_calculateWS(kytea::Kytea *kytea, char *sentence) {
  kytea::StringUtil *util = kytea->getStringUtil();

  kytea::KyteaString kytea_str = util->mapString(std::string(sentence));
  kytea::KyteaSentence kytea_sent(kytea_str, util->normalize(kytea_str));
  kytea->calculateWS(kytea_sent);

  const kytea::KyteaSentence::Words &words = kytea_sent.words;

  char **result = (char**)malloc(sizeof(char*) * (words.size() + 1));
  for (size_t i = 0; i < words.size(); i++) {
    result[i] = strdup(util->showString(words[i].surface).c_str());
  }
  result[words.size()] = NULL;

  return result;
}

void kytea_wrap_calculateWS_destory(char** result) {
  for (size_t i = 0; result[i] != NULL; i++) {
    free(result[i]);
  }
  free(result);
}


struct word* kytea_wrap_calculateTags(kytea::Kytea *kytea, char *sentence) {
  kytea::StringUtil *util = kytea->getStringUtil();

  kytea::KyteaString kytea_str = util->mapString(std::string(sentence));
  kytea::KyteaSentence kytea_sent(kytea_str, util->normalize(kytea_str));
  kytea->calculateWS(kytea_sent);

  for (int i = 0; i < kytea->getConfig()->getNumTags(); i++) {
    kytea->calculateTags(kytea_sent, i);
  }

  const kytea::KyteaSentence::Words &words = kytea_sent.words;

  struct word *result =
    (struct word*)malloc(sizeof(struct word) * (words.size() + 1));
  result[words.size()].surface = NULL;
  result[words.size()].tags = NULL;
  for (size_t i = 0; i < words.size(); i++) {
    result[i].surface = strdup(util->showString(words[i].surface).c_str());

    result[i].tags = (struct tag**)malloc(
        sizeof(struct tag*) * (words[i].tags.size() + 1));
    result[i].tags[words[i].tags.size()] = NULL;

    for (size_t j = 0; j < words[i].tags.size(); j++) {
      result[i].tags[j] = (struct tag*)malloc(
          sizeof(struct tag) * (words[i].tags[j].size() + 1));
      result[i].tags[j][words[i].tags[j].size()].name = NULL;
      result[i].tags[j][words[i].tags[j].size()].score = 0;

      for (size_t k = 0; k < words[i].tags[j].size(); k++) {
        result[i].tags[j][k].name =
          strdup(util->showString(words[i].tags[j][k].first).c_str());
        result[i].tags[j][k].score = words[i].tags[j][k].second;
      }
    }
  }
  return result;
}

void kytea_wrap_calculateTags_destroy(struct word *result) {
  for (size_t i = 0; result[i].surface != NULL; i++) {
    free(result[i].surface);

    for (size_t j = 0; result[i].tags[j] != NULL; j++) {
      for (size_t k = 0; result[i].tags[j][k].name != NULL; k++) {
        free(result[i].tags[j][k].name);
      }
      free(result[i].tags[j]);
    }
    free(result[i].tags);
  }
  free(result);
}

#ifdef __cplusplus
}; // extern "C"
#endif
