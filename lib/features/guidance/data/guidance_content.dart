/// نص بلغتين.
class LocalizedText {
  final String en;
  final String ar;

  const LocalizedText(this.en, this.ar);

  String of(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// بروتوكول إسعاف واحد.
class ProtocolDefinition {
  final String id;
  final LocalizedText title;
  final List<LocalizedText> steps;
  final LocalizedText? warning;
  final bool isGeneral;

  const ProtocolDefinition({
    required this.id,
    required this.title,
    required this.steps,
    this.warning,
    this.isGeneral = false,
  });
}

/// مكتبة الإرشادات الثابتة (بتشتغل من غير نت).
///
/// تنبيه: النصوص دي مبنية على إرشادات الإسعاف الأولي الشائعة،
/// لكن لازم تتراجع من متخصص (مدرّب إسعاف أو طبيب) قبل أي استخدام حقيقي أو تجربة.
class GuidanceContent {
  GuidanceContent._();

  // ───────────────────────── طبي ─────────────────────────

  static const medicalGeneral = ProtocolDefinition(
    id: 'medical_general',
    isGeneral: true,
    title: LocalizedText('Stay calm and keep everyone safe', 'حافظ على هدوئك وعلى سلامة الجميع'),
    steps: [
      LocalizedText(
        'Stay calm. Help is on the way and the dispatcher can see your location.',
        'حافظ على هدوئك. المساعدة في الطريق وغرفة العمليات ترى موقعك.',
      ),
      LocalizedText(
        'Make sure the area is safe for you and the patient (traffic, fire, electricity).',
        'تأكد أن المكان آمن لك وللمصاب (مرور، حريق، كهرباء).',
      ),
      LocalizedText(
        'Stay with the patient and keep them still and comfortable. Don’t move them unless there is danger.',
        'ابقَ بجانب المصاب واجعله ثابتًا ومرتاحًا. لا تحرّكه إلا إذا كان هناك خطر.',
      ),
      LocalizedText(
        'Don’t give food, drink, or medicine unless the dispatcher or a medical professional tells you to.',
        'لا تعطِه طعامًا أو شرابًا أو دواءً إلا إذا طلبت منك غرفة العمليات أو شخص مختص ذلك.',
      ),
      LocalizedText(
        'Unlock the door and ask someone to wait outside to guide the responders. Keep medicines and ID ready.',
        'افتح الباب واطلب من أحد الانتظار في الخارج لإرشاد المسعفين، وجهّز الأدوية والبطاقة الشخصية.',
      ),
      LocalizedText(
        'Reply quickly to the dispatcher’s messages.',
        'رُدّ بسرعة على رسائل غرفة العمليات.',
      ),
    ],
  );

  static const multipleInjured = ProtocolDefinition(
    id: 'medical_multiple_injured',
    title: LocalizedText('Several people are injured', 'عدة أشخاص مصابون'),
    steps: [
      LocalizedText(
        'First help anyone who is not responding, not breathing normally, or bleeding heavily.',
        'ابدأ بمن لا يستجيب أو لا يتنفس بشكل طبيعي أو ينزف بشدة.',
      ),
      LocalizedText(
        'Tell the dispatcher how many people need help and what is wrong with each one.',
        'أخبر غرفة العمليات بعدد المصابين وحالة كل واحد منهم.',
      ),
      LocalizedText(
        'Ask other people nearby to help you, one person per patient if possible.',
        'اطلب من الموجودين مساعدتك، وشخصًا لكل مصاب إن أمكن.',
      ),
    ],
  );

  static const cpr = ProtocolDefinition(
    id: 'medical_cpr',
    title: LocalizedText(
      'Not responding and not breathing normally',
      'لا يستجيب ولا يتنفس بشكل طبيعي',
    ),
    steps: [
      LocalizedText(
        'Tap their shoulders firmly and shout. If there is no response and no normal breathing (not breathing, or only gasping), start chest compressions.',
        'اضغط على كتفيه بقوة وناده بصوت عالٍ. إذا لم يستجب ولا يتنفس بشكل طبيعي (لا يتنفس أو يلهث فقط)، ابدأ ضغطات الصدر.',
      ),
      LocalizedText(
        'Put the heel of one hand on the center of the chest and your other hand on top.',
        'ضع كعب يدك في منتصف الصدر، وضع يدك الأخرى فوقها.',
      ),
      LocalizedText(
        'Push hard and fast: about 5 to 6 cm deep, 100 to 120 times a minute. Let the chest rise fully between pushes.',
        'اضغط بقوة وسرعة: بعمق نحو 5 إلى 6 سم وبمعدل 100 إلى 120 ضغطة في الدقيقة، واترك الصدر يرتفع بالكامل بين الضغطات.',
      ),
      LocalizedText(
        'Don’t stop until the ambulance arrives, the person starts breathing normally, or you are exhausted. If someone else is there, swap every 2 minutes.',
        'لا تتوقف حتى يصل الإسعاف أو يبدأ المصاب بالتنفس بشكل طبيعي أو تُرهَق. إن كان معك شخص آخر فبدّلا كل دقيقتين.',
      ),
      LocalizedText(
        'If an AED (defibrillator) is nearby, ask someone to bring it and follow its voice instructions.',
        'إن وُجد جهاز صدمات كهربائية (AED) قريب، اطلب من أحد إحضاره واتبع تعليماته الصوتية.',
      ),
    ],
    warning: LocalizedText(
      'Do this only if the person is not responding and not breathing normally.',
      'افعل هذا فقط إذا كان المصاب لا يستجيب ولا يتنفس بشكل طبيعي.',
    ),
  );

  static const bleeding = ProtocolDefinition(
    id: 'medical_bleeding',
    title: LocalizedText('Severe bleeding', 'نزيف شديد'),
    steps: [
      LocalizedText(
        'Press firmly on the wound with a clean cloth or your hand. Use a glove or a plastic bag if you have one.',
        'اضغط بقوة على الجرح بقطعة قماش نظيفة أو بيدك. استخدم قفازًا أو كيسًا بلاستيكيًا إن وُجد.',
      ),
      LocalizedText(
        'Keep pressing without stopping. If blood soaks through, add more cloth on top. Don’t remove the first one.',
        'استمر في الضغط دون توقف. إذا تشرّبت القماشة بالدم فضع قماشًا إضافيًا فوقها ولا تُزِل الأولى.',
      ),
      LocalizedText(
        'If the wound is on an arm or leg and there is no obvious broken bone, keep it raised.',
        'إذا كان الجرح في اليد أو الرجل ولا يوجد كسر واضح، فأبقِ العضو مرفوعًا.',
      ),
      LocalizedText(
        'Don’t remove objects stuck in the wound. Press around them.',
        'لا تُخرج أي جسم مغروس في الجرح، واضغط حوله.',
      ),
      LocalizedText(
        'Keep the person lying down and warm.',
        'أبقِ المصاب مستلقيًا ودافئًا.',
      ),
    ],
    warning: LocalizedText(
      'Use a tight band (tourniquet) only if you have been trained.',
      'لا تستخدم رباطًا ضاغطًا (تورنيكيه) إلا إذا كنت مدرّبًا.',
    ),
  );

  static const burns = ProtocolDefinition(
    id: 'medical_burns',
    title: LocalizedText('Burns', 'حروق'),
    steps: [
      LocalizedText(
        'Move away from the source of the burn. Remove rings, watches, or tight items near the burn, unless they are stuck to the skin.',
        'ابتعد عن مصدر الحرق. انزع الخواتم والساعات والأشياء الضيقة قرب الحرق ما لم تكن ملتصقة بالجلد.',
      ),
      LocalizedText(
        'Cool the burn under cool running water for 20 minutes.',
        'برّد الحرق تحت ماء جارٍ بارد لمدة 20 دقيقة.',
      ),
      LocalizedText(
        'Don’t use ice, butter, toothpaste, or ointments. Don’t pop blisters.',
        'لا تستخدم الثلج أو الزبدة أو معجون الأسنان أو المراهم، ولا تفقأ الفقاعات.',
      ),
      LocalizedText(
        'Cover loosely with a clean, non-fluffy cover such as cling film or a clean cloth.',
        'غطِّ الحرق بشكل فضفاض بغطاء نظيف غير مُوبِر مثل غلاف بلاستيكي شفاف أو قماش نظيف.',
      ),
      LocalizedText(
        'Keep the person warm and watch for signs of shock (pale, cold, weak, confused).',
        'أبقِ المصاب دافئًا وراقب علامات الصدمة (شحوب، برودة، ضعف، تشوّش).',
      ),
    ],
  );

  static const seizure = ProtocolDefinition(
    id: 'medical_seizure',
    title: LocalizedText('Seizure', 'تشنجات'),
    steps: [
      LocalizedText(
        'Clear the area around the person and cushion their head.',
        'أبعد أي أشياء حول المصاب وضع شيئًا ناعمًا تحت رأسه.',
      ),
      LocalizedText(
        'Don’t hold them down and don’t put anything in their mouth.',
        'لا تُثبّته بالقوة ولا تضع أي شيء في فمه.',
      ),
      LocalizedText(
        'Note the time the seizure started.',
        'سجّل وقت بداية التشنج.',
      ),
      LocalizedText(
        'When the shaking stops and they are breathing, gently turn them onto their side.',
        'عندما يتوقف التشنج ويتنفس، اقلبه برفق على جنبه.',
      ),
      LocalizedText(
        'Stay with them until they are fully awake. Tell the dispatcher if it lasts more than 5 minutes, or if they are injured or struggling to breathe.',
        'ابقَ معه حتى يفيق تمامًا. أخبر غرفة العمليات إذا استمر أكثر من 5 دقائق أو أُصيب أو واجه صعوبة في التنفس.',
      ),
    ],
  );

  static const choking = ProtocolDefinition(
    id: 'medical_choking',
    title: LocalizedText('Choking (adult)', 'اختناق (شخص بالغ)'),
    steps: [
      LocalizedText(
        'If the person can cough, encourage them to keep coughing.',
        'إذا كان المصاب يستطيع السعال، شجّعه على الاستمرار في السعال.',
      ),
      LocalizedText(
        'If they cannot speak, cough, or breathe: lean them forward and give up to 5 firm slaps between the shoulder blades.',
        'إذا لم يستطع الكلام أو السعال أو التنفس: أمِله للأمام واضربه حتى 5 ضربات قوية بين لوحي الكتف.',
      ),
      LocalizedText(
        'If that doesn’t work, stand behind them, put a fist above the belly button, and give up to 5 quick inward and upward thrusts.',
        'إذا لم ينجح ذلك، قف خلفه وضع قبضتك فوق السرّة، وادفع للداخل وللأعلى بسرعة حتى 5 مرات.',
      ),
      LocalizedText(
        'Keep alternating 5 slaps and 5 thrusts. If they become unresponsive, start chest compressions.',
        'استمر بالتناوب بين 5 ضربات و5 دفعات. إذا فقد الاستجابة فابدأ ضغطات الصدر.',
      ),
    ],
    warning: LocalizedText(
      'This is for adults and older children. Babies need a different technique, so tell the dispatcher.',
      'هذا للبالغين والأطفال الأكبر سنًا. الرضّع يحتاجون أسلوبًا مختلفًا، فأخبر غرفة العمليات.',
    ),
  );

  static const recoveryPosition = ProtocolDefinition(
    id: 'medical_recovery_position',
    title: LocalizedText(
      'Unconscious but breathing normally',
      'فاقد للوعي لكنه يتنفس بشكل طبيعي',
    ),
    steps: [
      LocalizedText(
        'Check that the chest is rising and breathing is normal.',
        'تأكد أن الصدر يتحرك وأن التنفس طبيعي.',
      ),
      LocalizedText(
        'Gently roll the person onto their side, with the head tilted back slightly and the mouth facing down so fluids can drain.',
        'اقلب المصاب برفق على جنبه، مع إمالة الرأس قليلًا للخلف وجعل الفم للأسفل ليخرج أي سائل.',
      ),
      LocalizedText(
        'Keep watching their breathing until help arrives. If it stops, start chest compressions.',
        'راقب تنفسه حتى تصل المساعدة. إذا توقف فابدأ ضغطات الصدر.',
      ),
      LocalizedText(
        'Don’t give anything by mouth.',
        'لا تعطه أي شيء عن طريق الفم.',
      ),
    ],
    warning: LocalizedText(
      'If you suspect a neck or back injury, move them as little as possible and tell the dispatcher.',
      'إذا اشتبهت في إصابة بالرقبة أو الظهر فحرّكه بأقل قدر ممكن وأخبر غرفة العمليات.',
    ),
  );

  static const List<ProtocolDefinition> medicalTopics = [
    cpr,
    bleeding,
    recoveryPosition,
    burns,
    seizure,
    choking,
  ];

  // ───────────────────────── حريق ─────────────────────────

  static const fireGeneral = ProtocolDefinition(
    id: 'fire_general',
    isGeneral: true,
    title: LocalizedText('Get out and stay safe', 'اخرج وابقَ في أمان'),
    steps: [
      LocalizedText(
        'Get out now. Don’t stop to collect belongings.',
        'اخرج فورًا ولا تتوقف لأخذ أغراضك.',
      ),
      LocalizedText(
        'Stay low under the smoke. Cover your nose and mouth with a cloth if you can.',
        'ابقَ منخفضًا تحت الدخان، وغطِّ أنفك وفمك بقطعة قماش إن أمكن.',
      ),
      LocalizedText(
        'Feel closed doors with the back of your hand. If a door is hot, don’t open it.',
        'المس الأبواب المغلقة بظهر يدك. إذا كان الباب ساخنًا فلا تفتحه.',
      ),
      LocalizedText(
        'Close doors behind you to slow the fire. Don’t use elevators.',
        'أغلق الأبواب خلفك لإبطاء الحريق، ولا تستخدم المصعد.',
      ),
      LocalizedText(
        'Go to a safe place outside, away from the building, and stay there. Never go back inside.',
        'اذهب إلى مكان آمن بعيدًا عن المبنى وابقَ فيه، ولا تعد إلى الداخل أبدًا.',
      ),
      LocalizedText(
        'If you are trapped: seal the gaps under the door with a wet cloth, go to a window, signal for help, and tell the dispatcher your floor and room.',
        'إذا حوصرت: سُدّ فتحات الباب بقماش مبلل، واذهب إلى نافذة، وأشر لطلب المساعدة، وأخبر غرفة العمليات بالطابق والغرفة.',
      ),
    ],
  );

  static const clothesOnFire = ProtocolDefinition(
    id: 'fire_clothes',
    title: LocalizedText('Clothes on fire', 'اشتعال الملابس'),
    steps: [
      LocalizedText(
        'Stop. Don’t run.',
        'توقف ولا تركض.',
      ),
      LocalizedText(
        'Drop to the ground and cover your face with your hands.',
        'اسقط على الأرض وغطِّ وجهك بيديك.',
      ),
      LocalizedText(
        'Roll over and over until the flames are out.',
        'تقلّب على الأرض حتى تنطفئ النيران.',
      ),
      LocalizedText(
        'Then cool the burn under cool running water for 20 minutes.',
        'ثم برّد الحرق تحت ماء جارٍ بارد لمدة 20 دقيقة.',
      ),
    ],
  );

  static const oilOrElectricalFire = ProtocolDefinition(
    id: 'fire_oil_electrical',
    title: LocalizedText('Cooking oil or electrical fire', 'حريق زيت أو كهرباء'),
    steps: [
      LocalizedText(
        'If it is safe, turn off the heat or the power.',
        'إذا كان ذلك آمنًا فأوقف مصدر الحرارة أو الكهرباء.',
      ),
      LocalizedText(
        'For a small fire in a pan, cover it with a lid.',
        'لحريق صغير في وعاء، غطِّه بغطاء.',
      ),
      LocalizedText(
        'If the fire spreads or you are not sure, leave immediately and close the door behind you.',
        'إذا انتشر الحريق أو لم تكن متأكدًا فاخرج فورًا وأغلق الباب خلفك.',
      ),
    ],
    warning: LocalizedText(
      'Never use water on an oil or electrical fire.',
      'لا تستخدم الماء أبدًا على حريق زيت أو كهرباء.',
    ),
  );

  static const List<ProtocolDefinition> fireTopics = [
    clothesOnFire,
    oilOrElectricalFire,
  ];

  // ───────────────────────── شرطة ─────────────────────────

  static const policeGeneral = ProtocolDefinition(
    id: 'police_general',
    isGeneral: true,
    title: LocalizedText('If you are in danger', 'إذا كنت في خطر'),
    steps: [
      LocalizedText(
        'Move to a safe place if you can, and lock or block the door.',
        'انتقل إلى مكان آمن إن أمكن، وأغلق الباب أو سدّه.',
      ),
      LocalizedText(
        'Stay quiet and silence your phone’s sound and vibration.',
        'التزم الهدوء وأوقف صوت هاتفك واهتزازه.',
      ),
      LocalizedText(
        'Don’t confront or chase anyone.',
        'لا تواجه أحدًا ولا تلاحقه.',
      ),
      LocalizedText(
        'Keep your phone with you and use the chat to update the dispatcher: what is happening, where, and how many people.',
        'أبقِ هاتفك معك واستخدم المحادثة لإبلاغ غرفة العمليات: ماذا يحدث وأين وكم شخصًا.',
      ),
      LocalizedText(
        'When the police arrive, keep your hands visible and follow their instructions.',
        'عند وصول الشرطة أبقِ يديك ظاهرتين واتبع تعليماتهم.',
      ),
      LocalizedText(
        'If you can, don’t touch things at the scene.',
        'إن أمكن، لا تلمس الأشياء في مكان الحادث.',
      ),
    ],
  );

  static const List<ProtocolDefinition> policeTopics = [];
}