import 'dart:core';

void main() {
  // ============================================================
  // SMART CAMPUS CANTEEN ENGINE
  // Course: Mobile Application Development (CSC303)
  // Lab Assignment: Week 3 & Week 4
  // ============================================================

  // ------------------------------------------------------------
  // TASK 1: STUDENT PROFILE SETUP
  // LLO-1: Variables & Data Types
  // ------------------------------------------------------------

  String studentName = "Muhammad Usman";
  String studentId = "SP24-BSE-001";
  double walletBalance = 1500.00;
  bool isHostelite = true;
  int loyaltyPoints = 125;

  // Active account for authorization
  bool isAccountActive = true;

  print("============================================================");
  print("              SMART CAMPUS CANTEEN ENGINE");
  print("============================================================");

  print("\n--- STUDENT PROFILE ---");
  print("Student Name   : $studentName");
  print("Student ID     : $studentId");
  print("Wallet Balance : Rs. ${walletBalance.toStringAsFixed(2)}");
  print("Hostelite      : $isHostelite");
  print("Loyalty Points : $loyaltyPoints");
  print("Account Active : $isAccountActive");

  // ------------------------------------------------------------
  // TASK 3: CANTEEN DATA MANAGEMENT
  // LLO-3: List, Set & Map
  // ------------------------------------------------------------

  // Map: Menu catalog with item prices
  Map<String, double> menuPrices = {
    "Chicken Roll": 180.0,
    "Zinger Burger": 350.0,
    "Fries": 150.0,
    "Coffee": 120.0,
    "Fresh Juice": 200.0,
  };

  // List: Items selected by student
  List<String> orderItems = [
    "Zinger Burger",
    "Chicken Roll",
    "Fries",
    "Coffee",
  ];

  // Set: Unique voucher codes
  Set<String> validVouchers = {"WELCOME10", "CAMPUS50", "EXAMBOOST"};

  // Student applies this voucher
  String appliedVoucher = "CAMPUS50";

  print("\n--- MENU CATALOG ---");

  menuPrices.forEach((item, price) {
    print("$item : Rs. ${price.toStringAsFixed(2)}");
  });

  print("\n--- SELECTED ORDER ---");

  for (String item in orderItems) {
    print("- $item");
  }

  // ------------------------------------------------------------
  // TASK 4: BILLING FUNCTIONS
  // LLO-4: Functions & Arrow Functions
  // ------------------------------------------------------------

  double subtotal = calculateTotal(orderItems, menuPrices);

  print("\nSubtotal: Rs. ${subtotal.toStringAsFixed(2)}");

  // ------------------------------------------------------------
  // TASK 2: ACCESS & DISCOUNT SYSTEM
  // LLO-2: Control Flow
  // ------------------------------------------------------------

  // Authorization check
  if (!isAccountActive || walletBalance <= 0) {
    print("\n❌ ORDER DENIED");
    print("Reason: Account is inactive or wallet balance is insufficient.");
    return;
  }

  print("\n✅ Account authorized.");
  print("Sufficient wallet balance detected.");

  // Calculate base discount according to student category
  double policyDiscount = calculatePolicyDiscount(
    subtotal,
    isHostelite,
    loyaltyPoints,
  );

  // Additional loyalty reduction
  double loyaltyDiscount = 0.0;

  if (loyaltyPoints > 100) {
    loyaltyDiscount = 50.0;
  }

  // Calculate amount after policy discount + loyalty discount
  double amountAfterDiscount = subtotal - policyDiscount - loyaltyDiscount;

  // Prevent negative bill
  if (amountAfterDiscount < 0) {
    amountAfterDiscount = 0;
  }

  // ------------------------------------------------------------
  // VOUCHER SYSTEM
  // ------------------------------------------------------------

  double voucherDiscount = 0.0;
  bool voucherApplied = false;

  if (validVouchers.contains(appliedVoucher)) {
    voucherApplied = true;

    // Voucher benefits
    if (appliedVoucher == "WELCOME10") {
      voucherDiscount = amountAfterDiscount * 0.10;
    } else if (appliedVoucher == "CAMPUS50") {
      voucherDiscount = 50.0;
    } else if (appliedVoucher == "EXAMBOOST") {
      voucherDiscount = 75.0;
    }

    // Remove voucher after successful use
    validVouchers.remove(appliedVoucher);

    print("\n🎟 Voucher '$appliedVoucher' applied successfully.");
    print("Voucher discount: Rs. ${voucherDiscount.toStringAsFixed(2)}");
  } else {
    print("\n⚠ Voucher '$appliedVoucher' is invalid or already used.");
  }

  // ------------------------------------------------------------
  // TAX CALCULATION
  // ------------------------------------------------------------

  // 5% tax on amount after all discounts
  double taxableAmount = amountAfterDiscount - voucherDiscount;

  if (taxableAmount < 0) {
    taxableAmount = 0;
  }

  double taxRate = 0.05;
  double tax = taxableAmount * taxRate;

  // Final amount
  double finalAmount = taxableAmount + tax;

  // ------------------------------------------------------------
  // WALLET BALANCE VALIDATION
  // ------------------------------------------------------------

  if (finalAmount > walletBalance) {
    print("\n============================================================");
    print("                    ⚠ INSUFFICIENT FUNDS");
    print("============================================================");
    print("Required Amount : Rs. ${finalAmount.toStringAsFixed(2)}");
    print("Wallet Balance  : Rs. ${walletBalance.toStringAsFixed(2)}");
    print(
      "Shortage        : Rs. "
      "${(finalAmount - walletBalance).toStringAsFixed(2)}",
    );
    print("Order cannot be processed.");
    return;
  }

  // ------------------------------------------------------------
  // UPDATE WALLET
  // ------------------------------------------------------------

  walletBalance -= finalAmount;

  // ------------------------------------------------------------
  // ITEMIZED RECEIPT
  // ------------------------------------------------------------

  print("\n============================================================");
  print("                     FINAL RECEIPT");
  print("============================================================");

  print("Student : $studentName");
  print("ID      : $studentId");
  print("------------------------------------------------------------");

  print("ITEM                         PRICE");
  print("------------------------------------------------------------");

  for (String item in orderItems) {
    double price = menuPrices[item] ?? 0.0;

    print(
      "${item.padRight(28)}"
      "Rs. ${price.toStringAsFixed(2)}",
    );
  }

  print("------------------------------------------------------------");
  print("Subtotal                     Rs. ${subtotal.toStringAsFixed(2)}");
  print(
    "Policy Discount              Rs. ${policyDiscount.toStringAsFixed(2)}",
  );
  print(
    "Loyalty Discount             Rs. ${loyaltyDiscount.toStringAsFixed(2)}",
  );
  print(
    "Voucher Discount             Rs. ${voucherDiscount.toStringAsFixed(2)}",
  );
  print("Tax (5%)                     Rs. ${tax.toStringAsFixed(2)}");
  print("------------------------------------------------------------");
  print("FINAL CHARGED AMOUNT         Rs. ${finalAmount.toStringAsFixed(2)}");
  print("Remaining Wallet Balance     Rs. ${walletBalance.toStringAsFixed(2)}");
  print("------------------------------------------------------------");

  if (voucherApplied) {
    print("Voucher Status               : USED");
  } else {
    print("Voucher Status               : NOT USED");
  }

  print("============================================================");
  print("              ORDER COMPLETED SUCCESSFULLY");
  print("============================================================");

  // Arrow function
  logTransaction(studentId, finalAmount);
}

// ============================================================
// FUNCTION 1: CALCULATE TOTAL
// Returns subtotal of selected items
// ============================================================

double calculateTotal(List<String> orderItems, Map<String, double> menuPrices) {
  double total = 0.0;

  for (String item in orderItems) {
    if (menuPrices.containsKey(item)) {
      total += menuPrices[item]!;
    } else {
      print("Warning: '$item' is not available in the menu.");
    }
  }

  return total;
}

// ============================================================
// FUNCTION 2: APPLY DISCOUNT
// Calculates net discounted price
// ============================================================

double applyDiscount(double subtotal, bool isHostelite, int loyaltyPoints) {
  double discount = calculatePolicyDiscount(
    subtotal,
    isHostelite,
    loyaltyPoints,
  );

  if (loyaltyPoints > 100) {
    discount += 50.0;
  }

  double netPrice = subtotal - discount;

  if (netPrice < 0) {
    netPrice = 0;
  }

  return netPrice;
}

// ============================================================
// HELPER FUNCTION: POLICY DISCOUNT
// ============================================================

double calculatePolicyDiscount(
  double subtotal,
  bool isHostelite,
  int loyaltyPoints,
) {
  double discount = 0.0;

  // Hostel student: 15% if bill exceeds Rs. 500
  if (isHostelite && subtotal > 500) {
    discount = subtotal * 0.15;
  }
  // Day scholar: 10% if bill exceeds Rs. 700
  else if (!isHostelite && subtotal > 700) {
    discount = subtotal * 0.10;
  }
  // Otherwise no percentage discount
  else {
    discount = 0.0;
  }

  return discount;
}

// ============================================================
// ARROW FUNCTION
// Concise transaction logging
// ============================================================

void logTransaction(String id, double amount) => print(
  "Transaction confirmed | Student ID: $id | "
  "Amount Charged: Rs. ${amount.toStringAsFixed(2)}",
);
