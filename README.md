# PureFinance (净账) - 跨平台记账应用开发文档

## 1. 产品概述

### 1.1 项目愿景

PureFinance 旨在打造一款结合了**钱迹**的极致简洁高效与 **MOZE** 的精美视觉体验的跨平台个人记账应用。我们致力于帮助用户轻松管理日常收支、有效追踪月付订阅，并通过直观的数据分析，实现更清晰的财务认知和更健康的消费习惯。本应用将支持 iOS、Android 和 Web 三个平台，确保用户在任何设备上都能获得一致且流畅的记账体验。

### 1.2 目标用户

*   **注重效率的个人用户**：希望快速记录每笔交易，不被繁琐操作打扰。
*   **订阅服务重度使用者**：需要有效管理各类月付/年付订阅，避免遗忘和浪费。
*   **追求财务清晰度的人群**：希望通过数据报表了解自己的消费构成和财务健康状况。
*   **对应用界面有较高要求者**：偏爱美观、直观、用户友好的设计。

## 2. 核心设计理念

PureFinance 的设计将围绕以下核心理念展开：

*   **简洁至上 (Simplicity First)**：借鉴钱迹的极简风格，减少不必要的视觉干扰和操作步骤，让记账回归本质。
*   **美学驱动 (Aesthetic Driven)**：汲取 MOZE 的设计精髓，提供优雅的界面、流畅的动画和赏心悦目的图表，提升用户使用愉悦感。
*   **智能自动化 (Smart Automation)**：通过周期账单、订阅提醒等功能，最大限度地减少用户手动操作，让财务管理更省心。
*   **跨平台一致性 (Cross-Platform Consistency)**：利用 Flutter 框架的优势，确保在 iOS、Android 和 Web 平台上提供统一且高质量的用户体验。

## 3. 功能模块解析

### 3.1 记账核心

*   **快速记账**：
    *   **入口**：首页显著位置的“+”按钮，支持一键快速记录。
    *   **录入**：支持金额、分类、账户、备注、日期、标签等基本信息录入。
    *   **智能识别**：尝试根据备注或历史记录智能推荐分类和标签。
*   **多账户管理**：
    *   **类型**：支持现金、银行卡、信用卡、储蓄账户、投资账户等多种账户类型。
    *   **余额**：实时显示各账户余额和总资产。
    *   **转账**：支持账户间资金划转记录。
*   **分类管理**：
    *   **自定义**：用户可自定义支出和收入分类，支持二级分类。
    *   **图标/颜色**：为分类设置个性化图标和颜色，提升视觉识别度。
*   **标签管理**：
    *   **灵活**：用户可创建自定义标签，为交易添加多维度标记（如“旅行”、“学习”、“人情”）。
    *   **筛选**：支持按标签筛选交易记录和报表。

### 3.2 订阅追踪

*   **订阅列表**：
    *   **概览**：清晰展示所有活跃订阅服务的名称、金额、周期、下次扣费日期。
    *   **状态**：区分“活跃”、“已暂停”、“已取消”等状态。
*   **周期设置**：
    *   **灵活**：支持月付、季付、年付、自定义周期等多种设置。
    *   **扣费日**：可指定每月/每年的具体扣费日期。
*   **到期提醒**：
    *   **提前通知**：在订阅服务扣费前 N 天（可自定义）发送提醒通知。
    *   **续订/取消**：提醒中提供快速续订或取消的指引。
*   **历史记录**：
    *   **追踪**：记录每次订阅扣费的实际日期和金额。
    *   **统计**：提供订阅服务的历史总支出。
*   **订阅统计**：
    *   **图表**：通过饼图或柱状图展示订阅支出在总支出中的占比，以及不同订阅服务的支出分布。
    *   **趋势**：分析订阅支出的月度/年度变化趋势。

### 3.3 预算管理

*   **月度/年度预算**：
    *   **设置**：用户可为总支出或特定分类设置月度/年度预算。
    *   **进度**：实时显示预算使用进度，通过进度条或颜色区分。
*   **预算超支提醒**：
    *   **预警**：当支出接近或超出预算时，发送通知提醒用户。

### 3.4 资产管理

*   **账户类型**：现金、银行卡、信用卡、储蓄、投资等。
*   **资产负债**：清晰展示总资产、总负债和净资产。
*   **负债管理**：针对信用卡等负债，提供还款提醒和账单管理。

### 3.5 报表分析

*   **支出趋势**：按周、月、年展示支出变化趋势图。
*   **收入构成**：饼图展示收入来源分布。
*   **分类分析**：柱状图或饼图展示各分类的支出占比。
*   **订阅支出分析**：详见 3.2 订阅追踪。

### 3.6 自动化

*   **周期账单自动生成**：基于订阅追踪和周期记账设置，自动在指定日期生成交易记录。
*   **支付平台账单导入 (可选)**：未来可考虑集成支付宝、微信支付等账单导入功能，进一步简化记账流程。

### 3.7 数据同步与备份

*   **云同步**：支持 iCloud/Google Drive/自定义云服务进行数据同步，确保多设备数据一致性。
*   **本地备份**：支持本地数据导出和导入，方便用户手动备份。

### 3.8 用户界面与体验 (UI/UX)

*   **主题**：支持浅色/深色主题切换。
*   **手势操作**：优化滑动、长按等手势操作，提升交互效率。
*   **自定义**：允许用户自定义首页布局、常用功能快捷入口等。

## 4. 技术选型

*   **前端框架**：**Flutter** (Dart 语言)
    *   **优势**：单 codebase 编译到 iOS、Android、Web，开发效率高，UI 渲染性能好，原生体验。
*   **状态管理**：Provider / Riverpod / BLoC (根据项目规模和团队偏好选择)
*   **数据存储**：
    *   **本地**：Hive (轻量级 NoSQL 数据库) 或 SQLite (通过 `sqflite` 插件)
    *   **云端**：Firebase Firestore (NoSQL 实时数据库) 或 Supabase (开源 Firebase 替代品，PostgreSQL)
*   **后端 (可选，用于高级功能如支付平台账单导入)**：Node.js / Python (FastAPI / Flask) + PostgreSQL / MongoDB
*   **通知服务**：Firebase Cloud Messaging (FCM) 用于跨平台推送通知。

## 5. 数据模型设计 (核心实体)

### 5.1 交易 (Transaction)

| 字段名 | 类型 | 描述 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | String | 唯一标识符 | `uuid-v4` |
| `type` | Enum | 交易类型：`expense`, `income`, `transfer` | `expense` |
| `amount` | Double | 交易金额 | `50.00` |
| `currency` | String | 货币类型 | `CNY` |
| `date` | DateTime | 交易日期和时间 | `2026-05-14T10:30:00Z` |
| `category_id` | String | 分类 ID (关联 Category) | `food_id` |
| `account_id` | String | 账户 ID (关联 Account) | `cash_id` |
| `notes` | String | 备注 | `午餐` |
| `tags` | List<String> | 标签列表 (关联 Tag) | `['外食', '工作日']` |
| `is_recurring` | Boolean | 是否为周期性交易 | `true` |
| `recurring_id` | String | 周期性交易 ID (关联 RecurringTransaction) | `netflix_sub_id` |

### 5.2 账户 (Account)

| 字段名 | 类型 | 描述 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | String | 唯一标识符 | `uuid-v4` |
| `name` | String | 账户名称 | `招商银行信用卡` |
| `type` | Enum | 账户类型：`cash`, `bank`, `credit_card`, `investment` | `credit_card` |
| `balance` | Double | 当前余额 | `1200.50` |
| `currency` | String | 货币类型 | `CNY` |
| `icon` | String | 账户图标 | `bank_icon.svg` |
| `color` | String | 账户颜色 | `#FF5733` |

### 5.3 分类 (Category)

| 字段名 | 类型 | 描述 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | String | 唯一标识符 | `uuid-v4` |
| `name` | String | 分类名称 | `餐饮` |
| `type` | Enum | 分类类型：`expense`, `income` | `expense` |
| `parent_id` | String | 父分类 ID (用于二级分类) | `food_id` |
| `icon` | String | 分类图标 | `food_icon.svg` |
| `color` | String | 分类颜色 | `#4CAF50` |

### 5.4 标签 (Tag)

| 字段名 | 类型 | 描述 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | String | 唯一标识符 | `uuid-v4` |
| `name` | String | 标签名称 | `旅行` |
| `color` | String | 标签颜色 | `#2196F3` |

### 5.5 周期性交易/订阅 (RecurringTransaction/Subscription)

| 字段名 | 类型 | 描述 | 示例 |
| :--- | :--- | :--- | :--- |
| `id` | String | 唯一标识符 | `uuid-v4` |
| `name` | String | 订阅/周期性交易名称 | `Netflix 会员` |
| `amount` | Double | 每次扣费金额 | `19.99` |
| `currency` | String | 货币类型 | `USD` |
| `start_date` | DateTime | 开始日期 | `2025-01-01` |
| `next_due_date` | DateTime | 下次扣费日期 | `2026-06-01` |
| `frequency` | Enum | 频率：`monthly`, `quarterly`, `yearly`, `custom` | `monthly` |
| `category_id` | String | 分类 ID (关联 Category) | `entertainment_id` |
| `account_id` | String | 账户 ID (关联 Account) | `credit_card_id` |
| `notes` | String | 备注 | `流媒体服务` |
| `status` | Enum | 状态：`active`, `paused`, `cancelled` | `active` |
| `remind_before_days` | Integer | 提前提醒天数 | `3` |

## 6. 核心代码实现 (Flutter 示例)

本节将提供 Flutter 核心功能模块的代码示例，主要关注数据模型定义、状态管理和 UI 结构。

### 6.1 数据模型定义 (Dart)

```dart
// transaction.dart
import 'package:flutter/foundation.dart';

enum TransactionType { expense, income, transfer }

@immutable
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String currency;
  final DateTime date;
  final String categoryId;
  final String accountId;
  final String? notes;
  final List<String>? tags;
  final bool isRecurring;
  final String? recurringId;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.currency,
    required this.date,
    required this.categoryId,
    required this.accountId,
    this.notes,
    this.tags,
    this.isRecurring = false,
    this.recurringId,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json["id"],
      type: TransactionType.values.firstWhere((e) => e.toString() == json["type"]),
      amount: json["amount"] as double,
      currency: json["currency"],
      date: DateTime.parse(json["date"]),
      categoryId: json["categoryId"],
      accountId: json["accountId"],
      notes: json["notes"],
      tags: (json["tags"] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isRecurring: json["isRecurring"] as bool,
      recurringId: json["recurringId"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "type": type.toString(),
      "amount": amount,
      "currency": currency,
      "date": date.toIso8601String(),
      "categoryId": categoryId,
      "accountId": accountId,
      "notes": notes,
      "tags": tags,
      "isRecurring": isRecurring,
      "recurringId": recurringId,
    };
  }
}

// account.dart
import 'package:flutter/foundation.dart';

enum AccountType { cash, bank, creditCard, investment }

@immutable
class Account {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? icon;
  final String? color;

  const Account({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.icon,
    this.color,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json["id"],
      name: json["name"],
      type: AccountType.values.firstWhere((e) => e.toString() == json["type"]),
      balance: json["balance"] as double,
      currency: json["currency"],
      icon: json["icon"],
      color: json["color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type.toString(),
      "balance": balance,
      "currency": currency,
      "icon": icon,
      "color": color,
    };
  }
}

// category.dart
import 'package:flutter/foundation.dart';

enum CategoryType { expense, income }

@immutable
class Category {
  final String id;
  final String name;
  final CategoryType type;
  final String? parentId;
  final String? icon;
  final String? color;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.parentId,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json["id"],
      name: json["name"],
      type: CategoryType.values.firstWhere((e) => e.toString() == json["type"]),
      parentId: json["parentId"],
      icon: json["icon"],
      color: json["color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "type": type.toString(),
      "parentId": parentId,
      "icon": icon,
      "color": color,
    };
  }
}

// tag.dart
import 'package:flutter/foundation.dart';

@immutable
class Tag {
  final String id;
  final String name;
  final String? color;

  const Tag({
    required this.id,
    required this.name,
    this.color,
  });

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(
      id: json["id"],
      name: json["name"],
      color: json["color"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "color": color,
    };
  }
}

// recurring_transaction.dart (Subscription)
import 'package:flutter/foundation.dart';

enum Frequency { monthly, quarterly, yearly, custom }
enum SubscriptionStatus { active, paused, cancelled }

@immutable
class RecurringTransaction {
  final String id;
  final String name;
  final double amount;
  final String currency;
  final DateTime startDate;
  final DateTime nextDueDate;
  final Frequency frequency;
  final String categoryId;
  final String accountId;
  final String? notes;
  final SubscriptionStatus status;
  final int remindBeforeDays;

  const RecurringTransaction({
    required this.id,
    required this.name,
    required this.amount,
    required this.currency,
    required this.startDate,
    required this.nextDueDate,
    required this.frequency,
    required this.categoryId,
    required this.accountId,
    this.notes,
    this.status = SubscriptionStatus.active,
    this.remindBeforeDays = 3,
  });

  factory RecurringTransaction.fromJson(Map<String, dynamic> json) {
    return RecurringTransaction(
      id: json["id"],
      name: json["name"],
      amount: json["amount"] as double,
      currency: json["currency"],
      startDate: DateTime.parse(json["startDate"]),
      nextDueDate: DateTime.parse(json["nextDueDate"]),
      frequency: Frequency.values.firstWhere((e) => e.toString() == json["frequency"]),
      categoryId: json["categoryId"],
      accountId: json["accountId"],
      notes: json["notes"],
      status: SubscriptionStatus.values.firstWhere((e) => e.toString() == json["status"]),
      remindBeforeDays: json["remindBeforeDays"] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "amount": amount,
      "currency": currency,
      "startDate": startDate.toIso8601String(),
      "nextDueDate": nextDueDate.toIso8601String(),
      "frequency": frequency.toString(),
      "categoryId": categoryId,
      "accountId": accountId,
      "notes": notes,
      "status": status.toString(),
      "remindBeforeDays": remindBeforeDays,
    };
  }
}
```

### 6.2 状态管理 (Provider 示例)

这里以 `Provider` 为例，展示如何管理应用状态。我们将创建 `TransactionProvider` 和 `SubscriptionProvider`。

```dart
// providers/transaction_provider.dart
import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    notifyListeners();
    // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
  }

  void updateTransaction(Transaction updatedTransaction) {
    final index = _transactions.indexWhere((t) => t.id == updatedTransaction.id);
    if (index != -1) {
      _transactions[index] = updatedTransaction;
      notifyListeners();
      // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
    }
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
  }

  // TODO: Implement methods for filtering, sorting, and fetching transactions from persistence layer
}

// providers/subscription_provider.dart
import 'package:flutter/foundation.dart';
import '../models/recurring_transaction.dart';

class SubscriptionProvider with ChangeNotifier {
  final List<RecurringTransaction> _subscriptions = [];

  List<RecurringTransaction> get subscriptions => _subscriptions;

  void addSubscription(RecurringTransaction subscription) {
    _subscriptions.add(subscription);
    notifyListeners();
    // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
  }

  void updateSubscription(RecurringTransaction updatedSubscription) {
    final index = _subscriptions.indexWhere((s) => s.id == updatedSubscription.id);
    if (index != -1) {
      _subscriptions[index] = updatedSubscription;
      notifyListeners();
      // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
    }
  }

  void deleteSubscription(String id) {
    _subscriptions.removeWhere((s) => s.id == id);
    notifyListeners();
    // TODO: Implement persistence logic (e.g., save to Hive/SQLite/Firestore)
  }

  // TODO: Implement methods for generating automatic transactions based on subscriptions.
  // This would involve checking nextDueDate and creating a Transaction if due, then persisting it.
}
```

### 6.3 UI 结构 (Flutter Widget 示例)

这里展示一个简化的订阅列表页面结构。

```dart
// screens/subscription_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../models/recurring_transaction.dart';

class SubscriptionListScreen extends StatelessWidget {
  const SubscriptionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Navigate to Add/Edit Subscription screen
            },
          ),
        ],
      ),
      body: Consumer<SubscriptionProvider>(
        builder: (context, subscriptionProvider, child) {
          if (subscriptionProvider.subscriptions.isEmpty) {
            return const Center(
              child: Text('暂无订阅服务，点击右上方添加'),
            );
          }
          return ListView.builder(
            itemCount: subscriptionProvider.subscriptions.length,
            itemBuilder: (context, index) {
              final subscription = subscriptionProvider.subscriptions[index];
              return SubscriptionCard(subscription: subscription);
            },
          );
        },
      ),
    );
  }
}

// widgets/subscription_card.dart
import 'package:flutter/material.dart';
import '../models/recurring_transaction.dart';
import 'package:intl/intl.dart'; // For date formatting

class SubscriptionCard extends StatelessWidget {
  final RecurringTransaction subscription;

  const SubscriptionCard({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subscription.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  '${subscription.currency} ${subscription.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '下次扣费: ${DateFormat('yyyy年MM月dd日').format(subscription.nextDueDate)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            Text(
              '周期: ${subscription.frequency == Frequency.monthly ? '每月' : subscription.frequency == Frequency.yearly ? '每年' : '自定义'}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
            // TODO: Add more details like category, account, status indicator
          ],
        ),
      ),
    );
  }
}
```

## 7. 参考资料

*   [Flutter 官方文档](https://flutter.dev/docs) - Flutter 框架的详细指南和 API 参考。
*   [Provider 状态管理](https://pub.dev/packages/provider) - Flutter 官方推荐的状态管理方案之一。
*   [Hive 数据库](https://pub.dev/packages/hive) - Flutter 的轻量级 NoSQL 数据库。
*   [sqflite 数据库](https://pub.dev/packages/sqflite) - Flutter 的 SQLite 插件。
*   [Firebase Firestore](https://firebase.google.com/docs/firestore) - Google 提供的 NoSQL 云数据库。
*   [Supabase](https://supabase.com/docs) - 开源的 Firebase 替代品，基于 PostgreSQL。
*   [钱迹官网](https://qianjiapp.com/) - 钱迹记账应用的官方网站。
*   [MOZE 官网](https://moze.app/) - MOZE 记账应用的官方网站。

---

**作者**：Manus AI
**日期**：2026年5月14日



---

## 8. Web 部署指引

PureFinance 在 Web 端使用 `sqflite_common_ffi_web`，**它依赖两个特殊的运行时文件**（`sqflite_sw.js` 和 `sqlite3.wasm`），如果不安装就直接 `flutter build web`，部署后会**白屏**。

### 一键脚本（推荐）

```bash
# 部署到站点根路径
./scripts/build_web.sh

# 部署到子路径，例如 https://example.com/finance/
./scripts/build_web.sh /finance/
```

完成后将 `build/web/` 目录的**所有内容**上传到服务器（或将该路径作为 nginx/Apache 的 document root）。

### 手动步骤

```bash
flutter pub get
dart run sqflite_common_ffi_web:setup        # 必须，生成 sqflite_sw.js 和 sqlite3.wasm
flutter build web --release                  # 默认 base href = /
# 或部署到子路径：
flutter build web --release --base-href=/finance/
```

### 部署常见坑

1. **白屏 / 加载动画转圈不停**：99% 是漏跑了 `dart run sqflite_common_ffi_web:setup`。检查 `build/web/` 下是否有 `sqflite_sw.js` 与 `sqlite3.wasm`。
2. **直接把 `web/` 上传到服务器** —— 不行。`web/` 只是源码目录，里面的 `index.html` 还带着 `$FLUTTER_BASE_HREF` 占位符。必须用 `flutter build web` 生成 `build/web/` 后再部署。
3. **部署在子路径但没传 `--base-href`**：浏览器会找不到 `main.dart.js` 等资源，控制台会出现 404。
4. **服务器需要正确的 MIME**：`.wasm` → `application/wasm`，`.js` → `application/javascript`。nginx 默认通常正确，老旧 Apache 可能需要在 `.htaccess` 中显式声明。
5. **HTTPS / Service Worker**：`sqflite_sw.js` 是 Service Worker，必须运行在 `https://` 或 `http://localhost`，纯 IP + http 部署时浏览器会拒绝注册。

部署后如果初始化仍然失败，应用会自动显示一个错误诊断页面（而不是白屏），上面会写明可能原因和需要执行的命令，便于排查。
