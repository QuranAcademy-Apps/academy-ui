import 'package:academy_islamic/academy_islamic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_catalog.dart';

void main() {
  const hy = '‑';
  const general = TranscriptionScheme.general;
  String tr(String arabic, [TranscriptionScheme s = general]) =>
      ArabicTranscriber.text(arabic, s);

  group('general Russian', () {
    test('reads vowels, doubled letters and the definite article', () {
      expect(tr('اللَّهُمَّ'), 'Аллахумма');
      expect(tr('الْجَنَّةَ'), 'Аль$hyджанната');
      expect(tr('رَبَّنَا'), 'Раббана');
      expect(tr('النَّارِ'), 'Ан$hyнари');
      expect(tr('الشَّهَادَةِ'), 'Аш$hyшахадати');
    });

    test('joins particles to the article and drops the elided alif', () {
      expect(tr('فِي الْجَنَّةِ'), 'Фи$hyль$hyджаннати');
      expect(tr('وَالْحَمْدُ'), 'Валь$hyхамду');
      expect(tr('بِالصَّالِحِينَ'), 'Бис$hyсалихина');
    });

    test('keeps lines and handles tanwin, hamza and ayn', () {
      expect(tr('أَعُوذُ بِكَ\nعِلْمًا'), 'А‘узу бика\n‘ильман');
      expect(tr('سَأَلَ'), 'Са’ала');
      expect(tr('عَلَىٰ'), '‘ала');
    });

    test('ignores brackets and reads a bare final ta marbuta in pause', () {
      expect(tr('(رَبَّنَا)'), 'Раббана');
      expect(tr('رَحْمَة'), 'Рахма');
      expect(tr(''), '');
    });
  });

  // Each expectation below is a stretch of a published transcription of the
  // same Arabic (see transcription-sources.md); only stretches that match
  // letter for letter and vowel for vowel are asserted, not pause forms.
  String plain(String text) => text.replaceAll(hy, '-');
  void same(TranscriptionScheme s, String arabic, String expected) =>
      expect(plain(tr(arabic, s)), expected);

  group('Vainakh (Chechen texts: steppenews.kz, an ok.ru azkar post; stress mark)', () {
    const s = TranscriptionScheme.vainakh;
    test('letters, long vowels (а́ у́ и́) and the glued article', () {
      same(s, 'اللَّهُمَّ أَنْتَ رَبِّي', 'Аллохӏумма анта робби');
      same(
        s,
        'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ',
        'Аллохӏумма иннака ӏафуввун тухьиббул-ӏафв',
      );
      same(s, 'رَبَّنَا آتِنَا', 'Роббана́ а́тина́');
      same(s, 'فِي الدُّنْيَا', 'Фид-дуня́');
      same(s, 'وَقِنَا', 'Ва къина́');
      same(s, 'يَا مُقَلِّبَ الْقُلُوبِ', 'Я́ мукъоллибал-къулу́б');
      same(s, 'إِنِّي', 'Инни');
      same(s, 'لا إِلَهَ', 'Ла́ илахӏ');
    });

    test('hamza is ’, wa- is its own word, ayn is ӏ', () {
      same(
        s,
        'أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ',
        'Абу́’у ляка биниӏматика ӏалайй',
      );
      same(s, 'أَعُوذُ بِكَ مِنْ شَرِّ', 'Аӏу́зу бика мин шарр');
      same(s, 'وَأَنَا عَلَى', 'Ва ана ӏала́');
      same(s, 'لَا إِلَهَ إِلَّا أَنْتَ', 'Ла́ илахӏа илла ант');
      same(s, 'خَلَقْتَنِي', 'Холакътани');
      same(
        s,
        'فَإِنَّهُ لا يَغْفِرُ الذُّنُوبَ',
        'Фа-иннахӏу ла́ ягӏфируз-зуну́б',
      );
    });

    test('tajwid: heavy letters take о, ظ is зӏ, nun merges into ل/ر', () {
      same(s, 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا', 'Роббана́ зӏоламна́ анфусана́');
      same(s, 'وَإِنْ لَّمْ تَغْفِرْ', 'Ва иль лям тагӏфир');
      same(s, 'مِنْ رَبِّهِ', 'Мир роббихӏ');
      same(s, 'قَلْبًا رَحِيمًا', 'Къольбар рохьи́ма́');
    });

    test('owner tajwid: о after heavy letters, ы for kasra after ص ض ط ظ', () {
      // The owner's examples «Родӏы́ту», «сыро́тӏо»; the ok.ru post writes
      // plain «ради́ту», «басари́», «мастатӏаӏту».
      same(s, 'رَضِيتُ بِاللَّهِ رَبًّا', 'Родӏы́ту билля́хӏи робба́');
      same(s, 'صِرَاطَ الَّذِينَ', 'Сыро́тӏол-лази́н');
      same(s, 'الْحَيُّ الْقَيُّومُ', 'Ал-хьаййул-къоййу́м');
      same(s, 'مَا اسْتَطَعْتُ', 'Мастатӏоӏт');
      same(s, 'بَصَرِي', 'Басори');
      same(s, 'وَالضَّالِّينَ', 'Вадӏ-дӏо́лли́н');
      same(s, 'خَلَقَ', 'Холакъ');
    });

    test(
      'stop: the last vowel goes, ta marbuta is хӏ, ج is дж, God capitalised',
      () {
        // The owner's examples: «минаннар», «джаннахӏ».
        same(s, 'مِنَ النَّارِ', 'Минан-на́р');
        same(s, 'فِي الْجَنَّةِ', 'Фил-джаннахӏ');
        same(s, 'حَسَنَةً', 'Хьасанахӏ');
        same(s, 'عِلْمًا', 'Ӏильма́');
        same(s, 'جَنَّةٌ وَاللَّهُ', 'Джаннатун валлохӏ');
        same(s, 'يَا اللَّهُ أَحَدٌ', 'Я́ Аллохӏу ахьад');
        same(s, 'لِلَّذِينَ آمَنُوا', 'Лиллази́на а́ману́');
      },
    );

    test('running text: only its very end is a stop, capitals open sentences', () {
      const arabic =
          'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْجَنَّةَ\nفَأَعُوذُ بِكَ مِنَ النَّارِ';
      same(
        s,
        arabic,
        'Аллохӏумма инни ас’алукал-джанната\nфа-аӏу́зу бика минан-на́р',
      );
      // Shown line by line, every line ends in a stop.
      expect(ArabicTranscriber.lines(arabic, s).map(plain), [
        'Аллохӏумма инни ас’алукал-джаннахӏ',
        'фа-аӏу́зу бика минан-на́р',
      ]);
      // The translation says where a sentence starts.
      final starts = ArabicTranscriber.sentenceStarts(
        'О Аллах, прошу Тебя о рае.\nПрибегаю к Тебе от огня!',
      );
      expect(starts, [true, true]);
      expect(
        ArabicTranscriber.lines(arabic, s, sentenceStarts: starts).last,
        startsWith('Фа'),
      );
      expect(ArabicTranscriber.sentenceStarts('один,\nдва…\n«три.»\nчетыре'), [
        true,
        false,
        true,
        true,
      ]);
      // The first line of a dua is still capitalised.
      same(s, 'وَأَعُوذُ بِكَ', 'Ва аӏу́зу бик');
    });

    test('a connecting alif after a vowel joins the word to the previous', () {
      same(s, 'بِسْمِ اللَّهِ الَّذِي', 'Бисмилля́хӏил-лази');
      same(s, 'سُبْحَانَ الَّذِي سَخَّرَ', 'Субхьа́нал-лази саххор');
      same(s, 'اللَّهُمَّ اسْتُرْ عَوْرَاتِي', 'Аллохӏуммастур ӏавро́ти');
      same(s, 'وَاغْفِرْ لَنَا', 'Вагӏфир ляна́');
      same(s, 'مَعَ اسْمِهِ', 'Маӏасмихӏ');
      // At the start of a line the alif is read.
      same(s, 'الَّذِي', 'Аллази');
    });

    test('the name of God after a particle and in the Hafs spelling', () {
      same(s, 'أَعُوذُ بِاللَّهِ', 'Аӏу́зу билля́хӏ');
      same(s, 'الْحَمْدُ لِلَّهِ رَبِّ', 'Ал-хьамду лилля́хӏи робб');
      same(s, 'فَلِلَّهِ الْحَمْدُ', 'Фалилля́хӏил-хьамд');
      same(
        s,
        'ٱللَّهُ لَآ إِلَـٰهَ إِلَّا هُوَ',
        'Аллохӏу ла́ ила́хӏа илла хӏув',
      );
    });

    test('Hafs spelling: tatweel, dotless ya, root waw, notes', () {
      // The dagger alif and the hamza written on a tatweel are read.
      same(s, 'فِى ٱلسَّمَـٰوَٰتِ', 'Фис-сама́ва́т');
      same(s, 'وَلَا يَـُٔودُهُۥ', 'Ва ла́ я’у́духӏ');
      // A dotless ya with a vowel or sukun is a consonant.
      same(s, 'ٱلْحَىُّ ٱلْقَيُّومُ', 'Ал-хьаййул-къоййу́м');
      same(s, 'بِشَىْءٍ', 'Бишай’');
      // A root waw is part of the word.
      same(s, 'وَسِعَ كُرْسِيُّهُ', 'Васиӏа курсиййухӏ');
      same(s, 'إِذَا وَقَبَ', 'Иза́ вакъоб');
      same(s, 'وَضَعْتُ جَنْبِي', 'Вадӏоӏту джанби');
      // An unvocalised note in brackets is not read, so the stop falls
      // on the last word of the dhikr.
      same(s, 'اللَّهُ أكْبَرُ (ثلاثاً وثلاثين)', 'Аллохӏу акбар');
      same(s, '(اللَّهُمَّ) فَاطِرَ', 'Аллохӏумма фа́тӏыр');
    });

    test('«йа» is «я»; wa- is split only from the conjunction', () {
      same(s, 'يَشْفَعُ', 'Яшфаӏ');
      same(s, 'وَحْدَهُ لَا شَرِيكَ لَهُ', 'Вахьдахӏу ла́ шари́ка ляхӏ');
      same(s, 'وَوَعْدِكَ', 'Ва ваӏдик');
      same(s, 'وَالِدَيَّ', 'Ва́лидайй');
    });

    // Azkaraш (нохчийн маттахь), App Store screenshots: сура «аль-Ихлас»
    // read with the pause forms of an aya end («ахьад», «ссомад», «роХьи́м»).
    test('Azkaraш: heavy and light lam of Аллаһ, ro, so, soft lam', () {
      same(
        s,
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        'Бисмилля́хӏир-рохьманир-рохьи́м',
      );
      same(s, 'قُلْ هُوَ اللَّهُ أَحَدٌ', 'Къуль хӏуваллохӏу ахьад');
      same(s, 'اللَّهُ الصَّمَدُ', 'Аллохӏус-сомад');
      same(s, 'لَمْ يَلِدْ وَلَمْ يُولَدْ', 'Лям ялид ва лям ю́лад');
      same(
        s,
        'وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ',
        'Ва лям якуль ляхӏу куфуван ахьад',
      );
    });

    test('a long vowel before an elided alif is read short', () {
      same(s, 'فِي الآخِرَةِ', 'Фил-а́хирохӏ');
      same(s, 'عَذَابَ النَّارِ', 'Ӏаза́бан-на́р');
    });
  });

  group('Tatar (nur.tatar, igelek.ru)', () {
    const s = TranscriptionScheme.tatar;
    test('long vowels, ж, һ and the back vowels after ق ص', () {
      same(s, 'وَإِذَا مَرِضْتُ', 'Вә изәә мәридът');
      same(s, 'وَيَشْفِ صُدُورَ', 'Вә йәшфи судүүр');
      same(s, 'لِلَّذِينَ ءَامَنُو', 'Лилләзиинә әәмәнүү');
      same(s, 'اَللَّهُمَّ أَنْتَ', 'Әллааһүммә әнт');
    });

    test('the article is glued to the previous word', () {
      same(s, 'وَنُنَزِّلُ مِنَ الْقُرْءَانِ', 'Вә нүнәззилү минәл-куръәән');
      same(s, 'الْقَائِمَةِ', 'Әл-каа’имәһ');
    });

    test('ө/ү follow the consonant: damma + waw reads үә, hamza э', () {
      same(s, 'فَهُوَ', 'Фәһүә');
      same(s, 'مُؤْمِنِينَ', 'Мүэминиин');
    });

    // ok.ru/tatarchado (догалар с арабским оригиналом) and tat.nur.tatar.
    test('ج is җ, a back letter with sukun takes ъ, kasra after it is ый', () {
      same(
        s,
        'اللَّهُمَّ جَنِّبْنَا الشَّيْطَانَ',
        'Әллааһүммә җәннибнәш-шәйтаан',
      );
      same(
        s,
        'رَبِّ زِدْنِى عِلْمًا وَفَهْمًا',
        'Рабби зиднии гыйльмән вә фәһмәә',
      );
      same(s, 'وَلِلْمُتَّقِينَ إِمَامًا', 'Вә лил-мүттәкыйинә имәәмәә');
    });

    test(
      'Аллаһ is light after a kasra, الَّذِي is glued, wa after a is вә',
      () {
        same(s, 'بِسْمِ اللَّهِ الرَّحِيمِ', 'Бисмилләәһир-рахиим');
        same(
          s,
          'سُبْحَانَ الَّذِى سَخَّرَ لَنَا',
          'Сүбхәәнәлләзии сәххара ләнәә',
        );
        same(
          s,
          'وَمَا فِي السَّمَاوَاتِ وَمَا',
          'Вә мәә фис-сәмәәвәәти вә мәә',
        );
      },
    );
  });

  group('Dagestani (Avar text)', () {
    const s = TranscriptionScheme.dagestan;
    test('гь, хӏ, гӏ and the doubled sun letter', () {
      same(
        s,
        'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
        'Бисмиллагьи ррахӏмани ррахӏими',
      );
      same(s, 'اللَّهُمَّ صَلِّ عَلَى', 'Аллагьумма салли гӏала');
      same(s, 'مُحَمَّدٍ وَسَلِّمْ', 'Мухӏаммадин ва саллим');
    });

    // The Avar post (ok.ru/group52826252050673, дуа Пророка Мусы) with the
    // Arabic text written out: ج ж, ض з, the article lam is plain «л».
    test(
      'Avar post: ж, з for ض, plain article л, «ллязи», no hamza after ā',
      () {
        same(s, 'بِاسْمِكَ الْعَظِيمِ الَّذِي', 'Бисмикал гӏазими ллязи');
        same(s, 'يَا أَرْحَمَ الرَّاحِمِينَ', 'Я архӏама ррахӏимина');
        same(s, 'رَجَاءَكَ', 'Ражаака');
        same(s, 'الْأَحْيَاءَ', 'Ал-ахӏяа');
        same(
          s,
          'وَقَاهِرَ كُلِّ شَيْءٍ بِقُدْرَتِكَ',
          'Ва къагьира кулли шайъин бикъудратика',
        );
        same(s, 'وَلَمْ تَبْلُغْهُ مَسْأَلَتِي', 'Ва лам таблугъгьу масъалати');
        same(s, 'ضَعُفَتْ عَنْهُ قُوَّتِي', 'Загӏуфат гӏангьу къуввати');
        same(
          s,
          'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنْتَ خَيْرُ الْوَارِثِينَ',
          'Рабби ла тазарни фардан ва анта хайрул варисина',
        );
      },
    );
  });

  test('general: the alif of Аллаһ is dropped after a vowel, lam is soft', () {
    expect(tr('بِسْمِ اللَّهِ'), 'Бисми$hyЛлахи');
    expect(tr('لَا إِلَهَ إِلَّا اللَّهُ'), 'Ла илаха илла$hyЛлаху');
    expect(tr('وَاللَّهُ أَكْبَرُ'), 'Ва$hyЛлаху акбару');
    expect(tr('بِاللَّهِ'), 'Би$hyЛлахи');
    expect(tr('مَا اسْتَطَعْتُ'), 'Ма$hyстата‘ту');
    expect(tr('بِسْمِ اللَّهِ الَّذِي'), 'Бисми$hyЛлахи$hyл$hyлази');
    expect(tr('لَقَدْ جَاءَكُمْ'), 'Лякад джа’акум');
    // The vocative keeps the alif.
    expect(tr('يَا اللَّهُ'), 'Я Аллаху');
  });

  test('the name of God is capitalised in the middle of a line', () {
    expect(tr('يَا اللَّهُ'), 'Я Аллаху');
    expect(plain(tr('اللَّهُمَّ')), 'Аллахумма');
  });

  group('over the whole corpus', () {
    final foreign = RegExp('[A-Za-z\\u0600-\\u06FF]');
    test(
      'every scheme reads every bundled dhikr into Cyrillic, line for line',
      () {
        final all = loadTestCatalog().all;
        for (final scheme in TranscriptionScheme.values) {
          for (final zikr in all) {
            final lines = ArabicTranscriber.lines(zikr.arabic, scheme);
            final reason = '${scheme.name} dhikr ${zikr.id}';
            expect(
              lines,
              hasLength(
                zikr.arabic
                    .split('\n')
                    .where((l) => l.trim().isNotEmpty)
                    .length,
              ),
              reason: reason,
            );
            for (final line in lines) {
              expect(line.trim(), isNotEmpty, reason: reason);
              expect(foreign.hasMatch(line), isFalse, reason: '$reason: $line');
            }
          }
        }
      },
    );
  });

  test('lines always line up with the non-empty Arabic lines', () {
    expect(ArabicTranscriber.lines('رَبَّنَا\n\n  \nآتِنَا', general), [
      'Раббана',
      'атина',
    ]);
    // A line with nothing to read is kept, not dropped.
    expect(
      ArabicTranscriber.lines('رَبَّنَا\n۝\nآتِنَا', general),
      hasLength(3),
    );
    expect(ArabicTranscriber.lines('', general), isEmpty);
  });

  test('ayah numbers and end-of-ayah signs are not read', () {
    expect(tr('رَبَّنَا ۝ ١٢'), 'Раббана');
  });
}
