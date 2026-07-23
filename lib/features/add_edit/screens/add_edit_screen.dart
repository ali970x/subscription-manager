import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/date_helper.dart';
import '../../../core/widgets/subscription_logo.dart';
import '../../../data/models/subscription_model.dart';
import '../../../providers/subscription_provider.dart';
import '../../../providers/category_provider.dart';
import '../widgets/billing_cycle_selector.dart';
import '../widgets/category_picker.dart';
import '../widgets/currency_picker.dart';

class AddEditScreen extends ConsumerStatefulWidget {
  const AddEditScreen({super.key, this.subscription, this.initialCategory});
  final SubscriptionModel? subscription;
  final String? initialCategory;
  @override
  ConsumerState<AddEditScreen> createState() => _AddEditScreenState();
}

class _AddEditScreenState extends ConsumerState<AddEditScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController priceController;
  late final TextEditingController notesController;
  late final TextEditingController emailController;
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController pinController;
  late final TextEditingController loginUrlController;
  late final TextEditingController codeUrlController;
  late String category;
  late String currency;
  late String cycle;
  late DateTime startDate;
  late DateTime renewalDate;
  late String colorHex;
  late bool notify;
  late int notifyDays;
  String? iconName;
  bool saving = false;
  late bool isPaid;
  late final TextEditingController paymentMethodController;
  DateTime? autoPaidOn;

  static const colors = [
    '#6C63FF',
    '#FF6584',
    '#00BFA6',
    '#4D96FF',
    '#FFB74D',
    '#9C7BEF',
    '#E85757',
  ];
  static const suggestions =
      <
        ({
          String name,
          double price,
          String category,
          String icon,
          String color,
          String cycle,
        })
      >[
        (
          name: 'ChatGPT',
          price: 4.5,
          category: 'ai_tools',
          icon: '✦',
          color: '#10A37F',
          cycle: 'monthly',
        ),
        (
          name: 'Gemini',
          price: 0,
          category: 'ai_tools',
          icon: '✦',
          color: '#8E75B2',
          cycle: 'monthly',
        ),
        (
          name: 'Claude',
          price: 0,
          category: 'ai_tools',
          icon: 'C',
          color: '#D97757',
          cycle: 'monthly',
        ),
        (
          name: 'Other AI Tool',
          price: 0,
          category: 'ai_tools',
          icon: '✦',
          color: '#10A37F',
          cycle: 'monthly',
        ),
        (
          name: 'Canva',
          price: 2.5,
          category: 'design_editing',
          icon: 'C',
          color: '#00B8D9',
          cycle: 'yearly',
        ),
        (
          name: 'CapCut',
          price: 6.5,
          category: 'design_editing',
          icon: 'C',
          color: '#15172A',
          cycle: 'monthly',
        ),
        (
          name: 'YouTube Premium',
          price: 4.5,
          category: 'others',
          icon: '▶',
          color: '#FF1744',
          cycle: 'monthly',
        ),
        (
          name: 'Netflix',
          price: 0,
          category: 'entertainment',
          icon: 'N',
          color: '#E50914',
          cycle: 'monthly',
        ),
        (
          name: 'Shahid',
          price: 0,
          category: 'entertainment',
          icon: 'ش',
          color: '#00BFA6',
          cycle: 'monthly',
        ),
        (
          name: 'Zest',
          price: 0,
          category: 'others',
          icon: 'Z',
          color: '#FF7A45',
          cycle: 'monthly',
        ),
        (
          name: '',
          price: 0,
          category: 'others',
          icon: '+',
          color: '#6C63FF',
          cycle: 'monthly',
        ),
      ];

  @override
  void initState() {
    super.initState();
    final item = widget.subscription;
    nameController = TextEditingController(text: item?.name ?? '');
    priceController = TextEditingController(
      text: item == null ? '' : item.price.toString(),
    );
    notesController = TextEditingController(text: item?.notes ?? '');
    emailController = TextEditingController(text: item?.email ?? '');
    usernameController = TextEditingController(text: item?.username ?? '');
    passwordController = TextEditingController(text: item?.password ?? '');
    pinController = TextEditingController(text: item?.pin ?? '');
    loginUrlController = TextEditingController(text: item?.loginUrl ?? '');
    codeUrlController = TextEditingController(text: item?.codeUrl ?? '');
    paymentMethodController = TextEditingController(
      text: item?.paymentMethod ?? '',
    );
    isPaid = item?.isPaid ?? false;
    autoPaidOn = item?.autoPaidOn;
    category = categoryById(
      ref.read(categoriesProvider),
      item?.category ?? widget.initialCategory ?? 'others',
    ).id;
    currency = item?.currency ?? 'USD';
    cycle = item?.billingCycle ?? 'monthly';
    startDate = item?.startDate ?? DateTime.now();
    renewalDate =
        item?.nextRenewalDate ?? DateHelper.nextRenewal(startDate, cycle);
    colorHex = item?.colorHex ?? colors.first;
    notify = item?.notifyBeforeRenewal ?? true;
    notifyDays = item?.notifyDaysBefore ?? 3;
    iconName = item?.iconName;
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    notesController.dispose();
    emailController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    pinController.dispose();
    loginUrlController.dispose();
    codeUrlController.dispose();
    paymentMethodController.dispose();
    super.dispose();
  }

  void recomputeRenewal() =>
      renewalDate = DateHelper.nextRenewal(startDate, cycle);

  Future<void> pasteAccountBlock() async {
    final text = (await Clipboard.getData(Clipboard.kTextPlain))?.text ?? '';
    if (text.trim().isEmpty) return;
    String value(RegExp pattern) =>
        pattern.firstMatch(text)?.group(1)?.trim() ?? '';
    final email =
        RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}').firstMatch(text)?.group(0) ??
        '';
    final urls = RegExp(
      r'https?://\S+',
    ).allMatches(text).map((e) => e.group(0)!).toList();
    setState(() {
      if (email.isNotEmpty) emailController.text = email;
      usernameController.text = value(
        RegExp(
          r'(?:user(?:name)?|login)\s*[:=-]\s*([^\r\n,]+)',
          caseSensitive: false,
        ),
      );
      passwordController.text = value(
        RegExp(
          r'(?:pass(?:word)?|pwd)\s*[:=-]\s*([^\r\n,]+)',
          caseSensitive: false,
        ),
      );
      pinController.text = value(
        RegExp(r'pin\s*[:=-]\s*([^\r\n,]+)', caseSensitive: false),
      );
      if (urls.isNotEmpty) {
        loginUrlController.text = urls.first;
      }
      if (urls.length > 1) {
        codeUrlController.text = urls[1];
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Account details pasted')));
    }
  }

  Future<void> pickDate(bool renewal) async {
    final initial = renewal ? renewalDate : startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2010),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (renewal) {
        renewalDate = picked;
      } else {
        startDate = picked;
        recomputeRenewal();
      }
    });
  }

  void applySuggestion(
    ({
      String name,
      double price,
      String category,
      String icon,
      String color,
      String cycle,
    })
    item,
  ) {
    setState(() {
      nameController.text = item.name;
      priceController.text = item.name.isEmpty
          ? ''
          : item.price.toStringAsFixed(2);
      category = item.category;
      iconName = item.icon;
      colorHex = item.color;
      cycle = item.cycle;
      recomputeRenewal();
    });
  }

  Future<void> save() async {
    if (!formKey.currentState!.validate()) return;
    setState(() => saving = true);
    final previous = widget.subscription;
    final item = SubscriptionModel(
      id: previous?.id ?? const Uuid().v4(),
      name: nameController.text.trim(),
      category: category,
      price: double.parse(priceController.text.trim()),
      currency: currency,
      billingCycle: cycle,
      startDate: startDate,
      nextRenewalDate: renewalDate,
      notes: notesController.text.trim().isEmpty
          ? null
          : notesController.text.trim(),
      iconName: iconName,
      colorHex: colorHex,
      isActive: previous?.isActive ?? true,
      notifyBeforeRenewal: notify,
      notifyDaysBefore: notifyDays,
      email: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      username: usernameController.text.trim().isEmpty
          ? null
          : usernameController.text.trim(),
      password: passwordController.text.trim().isEmpty
          ? null
          : passwordController.text.trim(),
      pin: pinController.text.trim().isEmpty ? null : pinController.text.trim(),
      loginUrl: loginUrlController.text.trim().isEmpty
          ? null
          : loginUrlController.text.trim(),
      codeUrl: codeUrlController.text.trim().isEmpty
          ? null
          : codeUrlController.text.trim(),
      isPaid: isPaid,
      paymentMethod: paymentMethodController.text.trim().isEmpty
          ? null
          : paymentMethodController.text.trim(),
      paidAt: isPaid ? (previous?.paidAt ?? DateTime.now()) : null,
      autoPaidOn: isPaid ? null : autoPaidOn,
    );
    await ref.read(subscriptionsProvider.notifier).save(item);
    if (!mounted) return;
    setState(() => saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(context.l10n.text('saved'))));
    Navigator.pop(context);
  }

  Future<void> delete() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.text('confirmDelete')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.text('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.text('delete')),
          ),
        ],
      ),
    );
    if (accepted != true || widget.subscription == null) return;
    await ref
        .read(subscriptionsProvider.notifier)
        .delete(widget.subscription!.id);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).languageCode,
    );
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n.text(widget.subscription == null ? 'add' : 'edit'),
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          if (widget.subscription != null)
            IconButton(
              onPressed: delete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
          children: [
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: FilledButton.tonalIcon(
                onPressed: pasteAccountBlock,
                icon: const Icon(Icons.content_paste_rounded),
                label: const Text('Paste account details'),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              context.l10n.text('suggestions'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: suggestions
                    .map(
                      (item) => Padding(
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ActionChip(
                          avatar: SubscriptionLogo(
                            name: item.name,
                            fallback: item.icon,
                            size: 25,
                            showBackground: false,
                          ),
                          label: Text(
                            item.name.isEmpty
                                ? context.l10n.text('otherSubscription')
                                : item.name,
                          ),
                          onPressed: () => applySuggestion(item),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.text('name'),
                prefixIcon: const Icon(Icons.subscriptions_outlined),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? context.l10n.text('required')
                  : null,
            ),
            const SizedBox(height: 20),
            CategoryPicker(
              value: category,
              onChanged: (value) => setState(() => category = value),
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: context.l10n.text('price'),
                      prefixIcon: const Icon(Icons.payments_outlined),
                    ),
                    validator: (value) =>
                        double.tryParse(value ?? '') == null ||
                            double.parse(value!) < 0
                        ? context.l10n.text('invalidPrice')
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CurrencyPicker(
                    value: currency,
                    onChanged: (value) => setState(() => currency = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            BillingCycleSelector(
              value: cycle,
              onChanged: (value) => setState(() {
                cycle = value;
                recomputeRenewal();
              }),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _DateField(
                    label: context.l10n.text('startDate'),
                    value: dateFormat.format(startDate),
                    onTap: () => pickDate(false),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateField(
                    label: context.l10n.text('nextRenewal'),
                    value: dateFormat.format(renewalDate),
                    onTap: () => pickDate(true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: notesController,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.l10n.text('notes'),
                prefixIcon: const Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Account access',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            _AccountField(
              controller: emailController,
              label: 'Email',
              icon: Icons.email_outlined,
            ),
            _AccountField(
              controller: usernameController,
              label: 'Username / User',
              icon: Icons.person_outline_rounded,
            ),
            _AccountField(
              controller: passwordController,
              label: 'Password',
              icon: Icons.password_rounded,
              obscure: true,
            ),
            _AccountField(
              controller: pinController,
              label: 'PIN (optional)',
              icon: Icons.pin_outlined,
            ),
            _AccountField(
              controller: loginUrlController,
              label: 'App / login link',
              icon: Icons.link_rounded,
            ),
            _AccountField(
              controller: codeUrlController,
              label: 'Sign-in code link',
              icon: Icons.key_rounded,
            ),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: isPaid,
                    onChanged: (value) => setState(() => isPaid = value),
                    secondary: Icon(
                      isPaid
                          ? Icons.check_circle_rounded
                          : Icons.schedule_rounded,
                    ),
                    title: Text(isPaid ? 'Paid' : 'Payment pending'),
                    subtitle: const Text(
                      'Track payment at the end of the month',
                    ),
                  ),
                  if (isPaid)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      child: TextFormField(
                        controller: paymentMethodController,
                        decoration: const InputDecoration(
                          labelText: 'Payment method',
                          hintText: 'Cash, card, transfer...',
                        ),
                      ),
                    ),
                  if (!isPaid) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      value: autoPaidOn != null,
                      onChanged: (value) async {
                        if (!value) {
                          setState(() => autoPaidOn = null);
                          return;
                        }
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(
                            const Duration(days: 1),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => autoPaidOn = picked);
                      },
                      secondary: const Icon(Icons.event_available_rounded),
                      title: const Text('Auto paid on'),
                      subtitle: Text(
                        autoPaidOn == null
                            ? 'Off'
                            : DateFormat.yMMMd().format(autoPaidOn!),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.l10n.text('cardColor'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: colors.map((hex) {
                final color = Color(
                  int.parse(hex.substring(1), radix: 16) + 0xFF000000,
                );
                return Semantics(
                  label: hex,
                  button: true,
                  selected: colorHex == hex,
                  child: InkWell(
                    onTap: () => setState(() => colorHex = hex),
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: colorHex == hex
                            ? Border.all(
                                color: Theme.of(context).colorScheme.onSurface,
                                width: 3,
                              )
                            : null,
                      ),
                      child: colorHex == hex
                          ? const Icon(
                              Icons.check_rounded,
                              size: 20,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: notify,
                    onChanged: (value) => setState(() => notify = value),
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(context.l10n.text('reminder')),
                  ),
                  if (notify)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: DropdownButtonFormField<int>(
                        initialValue: notifyDays,
                        decoration: InputDecoration(
                          labelText: context.l10n.text('reminderDays'),
                        ),
                        items: [1, 3, 7]
                            .map(
                              (day) => DropdownMenuItem(
                                value: day,
                                child: Text(
                                  context.l10n.text(
                                    day == 1
                                        ? 'oneDay'
                                        : day == 3
                                        ? 'threeDays'
                                        : 'sevenDays',
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) =>
                            setState(() => notifyDays = value ?? 3),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: saving ? null : () => Navigator.pop(context),
                child: Text(context.l10n.text('cancel')),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: saving ? null : save,
                icon: saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(context.l10n.text('save')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.calendar_today_outlined),
      ),
      child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
    ),
  );
}

class _AccountField extends StatefulWidget {
  const _AccountField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscure = false,
  });
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;

  @override
  State<_AccountField> createState() => _AccountFieldState();
}

class _AccountFieldState extends State<_AccountField> {
  late bool hidden = widget.obscure;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: widget.controller,
      obscureText: hidden,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.obscure)
              IconButton(
                onPressed: () => setState(() => hidden = !hidden),
                icon: Icon(
                  hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            IconButton(
              onPressed: () => Clipboard.setData(
                ClipboardData(text: widget.controller.text),
              ),
              icon: const Icon(Icons.copy_rounded),
            ),
          ],
        ),
      ),
    ),
  );
}
