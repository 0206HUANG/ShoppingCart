enum InvoiceType { personal, company, vatInvoice }

class Invoice {
  final String id;
  final InvoiceType type;
  final String title; // Name or company name
  final String? taxNumber; // For company and VAT invoices
  final String? companyAddress; // For company and VAT invoices
  final String? companyPhone; // For company and VAT invoices
  final String? bankAccount; // For VAT invoices
  final String? bankName; // For VAT invoices

  Invoice({
    required this.id,
    required this.type,
    required this.title,
    this.taxNumber,
    this.companyAddress,
    this.companyPhone,
    this.bankAccount,
    this.bankName,
  });

  bool get isVatInvoice => type == InvoiceType.vatInvoice;
  bool get isCompanyInvoice => type == InvoiceType.company;
  bool get isPersonalInvoice => type == InvoiceType.personal;
}
