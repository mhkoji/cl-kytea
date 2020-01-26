#include <kytea/kytea.h>
#include <kytea/string-util.h>
#include <vector>
#include <string>
#include <cstring>
#include <cstdlib>

#ifdef __cplusplus
extern "C" {
#endif

// g++ -shared -fPIC -o libkytea_wrap.so kytea_wrap.cpp

kytea::Kytea* kytea_wrap_new() {
  kytea::KyteaConfig *config = new kytea::KyteaConfig();
  config->setOnTraining(false);

  kytea::Kytea *kytea = new kytea::Kytea(config);
  kytea->readModel(config->getModelFile().c_str());
  return kytea;
}

char** kytea_wrap_calculateWS(kytea::Kytea *kytea, char *sentence) {
  kytea::StringUtil *util = kytea->getStringUtil();

  kytea::KyteaString kytea_str = util->mapString(std::string(sentence));
  kytea::KyteaSentence kytea_sent(kytea_str, util->normalize(kytea_str));
  kytea->calculateWS(kytea_sent);

  const kytea::KyteaSentence::Words &words = kytea_sent.words;

  char** result = (char**)malloc(sizeof(char*) * (words.size() + 1));
  for (size_t i = 0; i < words.size(); i++) {
    result[i] = strdup(util->showString(words[i].surface).c_str());
  }
  result[words.size()] = NULL;

  return result;
}

#ifdef __cplusplus
}; // extern "C"
#endif
