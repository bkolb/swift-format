//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

import Foundation

/// A version number that can be specified in the configuration file, which allows us to change the
/// format in the future if desired and still support older files.
///
/// Note that *adding* new configuration values is not a version-breaking change; swift-format will
/// use default values when loading older configurations that don't contain the new settings. This
/// value only needs to be updated if the configuration changes in a way that would be incompatible
/// with the previous format.
internal let highestSupportedConfigurationVersion = 1

/// Holds the complete set of configured values and defaults.
public struct Configuration: Codable, Equatable {

  public enum RuleSeverity: String, Codable, CaseIterable, Equatable, Sendable {
    case warning = "warning"
    case error = "error"
  }

  private enum CodingKeys: CodingKey {
    case version
    case maximumBlankLines
    case lineLength
    case spacesBeforeEndOfLineComments
    case tabWidth
    case indentation
    case respectsExistingLineBreaks
    case lineBreakBeforeControlFlowKeywords
    case lineBreakBeforeEachArgument
    case lineBreakBeforeEachGenericRequirement
    case lineBreakBetweenDeclarationAttributes
    case prioritizeKeepingFunctionOutputTogether
    case indentConditionalCompilationBlocks
    case lineBreakAroundMultilineExpressionChainComponents
    case fileScopedDeclarationPrivacy
    case indentSwitchCaseLabels
    case rules
    case ruleSeverity
    case spacesAroundRangeFormationOperators
    case noAssignmentInExpressions
    case multiElementCollectionTrailingCommas
    case reflowMultilineStringLiterals
    case indentBlankLines
  }

  /// A dictionary containing the default enabled/disabled states of rules, keyed by the rules'
  /// names.
  ///
  /// This value is generated by `generate-swift-format` based on the `isOptIn` value of each rule.
  public static let defaultRuleEnablements: [String: Bool] = RuleRegistry.rules

  /// The version of this configuration.
  private var version: Int = highestSupportedConfigurationVersion

  /// MARK: Common configuration

  /// The dictionary containing the rule names that we wish to run on. A rule is not used if it is
  /// marked as `false`, or if it is missing from the dictionary.
  public var rules: [String: Bool]

  /// The dictionary containing the severities for the rule names that we wish to run on. If a rule
  /// is not listed here, the default severity is used.
  public var ruleSeverity: [String: RuleSeverity]

  /// The maximum number of consecutive blank lines that may appear in a file.
  public var maximumBlankLines: Int

  /// The maximum length of a line of source code, after which the formatter will break lines.
  public var lineLength: Int

  /// Number of spaces that precede line comments.
  public var spacesBeforeEndOfLineComments: Int

  /// The width of the horizontal tab in spaces.
  ///
  /// This value is used when converting indentation types (for example, from tabs into spaces).
  public var tabWidth: Int

  /// A value representing a single level of indentation.
  ///
  /// All indentation will be conducted in multiples of this configuration.
  public var indentation: Indent

  /// Indicates that the formatter should try to respect users' discretionary line breaks when
  /// possible.
  ///
  /// For example, a short `if` statement and its single-statement body might be able to fit on one
  /// line, but for readability the user might break it inside the curly braces. If this setting is
  /// true, those line breaks will be kept. If this setting is false, the formatter will act more
  /// "opinionated" and collapse the statement onto a single line.
  public var respectsExistingLineBreaks: Bool

  /// MARK: Rule-specific configuration

  /// Determines the line-breaking behavior for control flow keywords that follow a closing brace,
  /// like `else` and `catch`.
  ///
  /// If true, a line break will be added before the keyword, forcing it onto its own line. If
  /// false (the default), the keyword will be placed after the closing brace (separated by a
  /// space).
  public var lineBreakBeforeControlFlowKeywords: Bool

  /// Determines the line-breaking behavior for generic arguments and function arguments when a
  /// declaration is wrapped onto multiple lines.
  ///
  /// If false (the default), arguments will be laid out horizontally first, with line breaks only
  /// being fired when the line length would be exceeded. If true, a line break will be added before
  /// each argument, forcing the entire argument list to be laid out vertically.
  public var lineBreakBeforeEachArgument: Bool

  /// Determines the line-breaking behavior for generic requirements when the requirements list
  /// is wrapped onto multiple lines.
  ///
  /// If true, a line break will be added before each requirement, forcing the entire requirements
  /// list to be laid out vertically. If false (the default), requirements will be laid out
  /// horizontally first, with line breaks only being fired when the line length would be exceeded.
  public var lineBreakBeforeEachGenericRequirement: Bool

  /// If true, a line break will be added between adjacent attributes.
  public var lineBreakBetweenDeclarationAttributes: Bool

  /// Determines if function-like declaration outputs should be prioritized to be together with the
  /// function signature right (closing) parenthesis.
  ///
  /// If false (the default), function output (i.e. throws, return type) is not prioritized to be
  /// together with the signature's right parenthesis, and when the line length would be exceeded,
  /// a line break will be fired after the function signature first, indenting the declaration output
  /// one additional level. If true, A line break will be fired further up in the function's
  /// declaration (e.g. generic parameters, parameters) before breaking on the function's output.
  public var prioritizeKeepingFunctionOutputTogether: Bool

  /// Determines the indentation behavior for `#if`, `#elseif`, and `#else`.
  public var indentConditionalCompilationBlocks: Bool

  /// Determines whether line breaks should be forced before and after multiline components of
  /// dot-chained expressions, such as function calls and subscripts chained together through member
  /// access (i.e. "." expressions). When any component is multiline and this option is true, a line
  /// break is forced before the "." of the component and after the component's closing delimiter
  /// (i.e. right paren, right bracket, right brace, etc.).
  public var lineBreakAroundMultilineExpressionChainComponents: Bool

  /// Determines the formal access level (i.e., the level specified in source code) for file-scoped
  /// declarations whose effective access level is private to the containing file.
  public var fileScopedDeclarationPrivacy: FileScopedDeclarationPrivacyConfiguration

  /// Determines if `case` statements should be indented compared to the containing `switch` block.
  ///
  /// When `false`, the correct form is:
  /// ```swift
  /// switch someValue {
  /// case someCase:
  ///   someStatement
  /// ...
  /// }
  /// ```
  ///
  /// When `true`, the correct form is:
  /// ```swift
  /// switch someValue {
  ///   case someCase:
  ///     someStatement
  ///   ...
  /// }
  ///```
  public var indentSwitchCaseLabels: Bool

  /// Determines whether whitespace should be forced before and after the range formation operators
  /// `...` and `..<`.
  public var spacesAroundRangeFormationOperators: Bool

  /// Contains exceptions for the `NoAssignmentInExpressions` rule.
  public var noAssignmentInExpressions: NoAssignmentInExpressionsConfiguration

  /// Determines if multi-element collection literals should have trailing commas.
  ///
  /// When `true` (default), the correct form is:
  /// ```swift
  /// let MyCollection = [1, 2]
  /// ...
  /// let MyCollection = [
  ///   "a": 1,
  ///   "b": 2,
  /// ]
  /// ```
  ///
  /// When `false`, the correct form is:
  /// ```swift
  /// let MyCollection = [1, 2]
  /// ...
  /// let MyCollection = [
  ///   "a": 1,
  ///   "b": 2
  /// ]
  /// ```
  public var multiElementCollectionTrailingCommas: Bool

  /// Determines how multiline string literals should reflow when formatted.
  public enum MultilineStringReflowBehavior: Codable {
    /// Never reflow multiline string literals.
    case never
    /// Reflow lines in string literal that exceed the maximum line length. For example with a line length of 10:
    /// ```swift
    /// """
    /// an escape\
    ///  line break
    /// a hard line break
    /// """
    /// ```
    /// will be formatted as:
    /// ```swift
    /// """
    /// an esacpe\
    ///  line break
    /// a hard \
    /// line break
    /// """
    /// ```
    /// The existing `\` is left in place, but the line over line length is broken.
    case onlyLinesOverLength
    /// Always reflow multiline string literals, this will ignore existing escaped newlines in the literal and reflow each line. Hard linebreaks are still respected.
    /// For example, with a line length of 10:
    /// ```swift
    /// """
    /// one \
    /// word \
    /// a line.
    /// this is too long.
    /// """
    /// ```
    /// will be formatted as:
    /// ```swift
    /// """
    /// one word \
    /// a line.
    /// this is \
    /// too long.
    /// """
    /// ```
    case always

    var isNever: Bool {
      switch self {
      case .never:
        return true
      default:
        return false
      }
    }

    var isAlways: Bool {
      switch self {
      case .always:
        return true
      default:
        return false
      }
    }
  }

  public var reflowMultilineStringLiterals: MultilineStringReflowBehavior

  /// Determines whether to add indentation whitespace to blank lines or remove it entirely.
  ///
  /// If true, blank lines will be modified to match the current indentation level:
  /// if they contain whitespace, the existing whitespace will be adjusted, and if they are empty, spaces will be added to match the indentation.
  /// If false (the default), the whitespace in blank lines will be removed entirely.
  public var indentBlankLines: Bool

  /// Creates a new `Configuration` by loading it from a configuration file.
  public init(contentsOf url: URL) throws {
    let data = try Data(contentsOf: url)
    try self.init(data: data)
  }

  /// Creates a new `Configuration` by decoding it from the UTF-8 representation in the given data.
  public init(data: Data) throws {
    self = try JSONDecoder().decode(Configuration.self, from: data)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    // If the version number is not present, assume it is 1.
    self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
    guard version <= highestSupportedConfigurationVersion else {
      throw DecodingError.dataCorruptedError(
        forKey: .version,
        in: container,
        debugDescription:
          "This version of the formatter does not support configuration version \(version)."
      )
    }

    // If we ever introduce a new version, this is where we should switch on the decoded version
    // number and dispatch to different decoding methods.

    // Unfortunately, to allow the user to leave out configuration options in the JSON, we would
    // have to make them optional properties, but that makes using the type in the rest of the code
    // more annoying because we'd have to unwrap everything. So, we override this initializer and
    // provide the defaults ourselves if needed. We get those defaults by pulling them from a
    // default-initialized instance.
    let defaults = Configuration()

    self.maximumBlankLines =
      try container.decodeIfPresent(Int.self, forKey: .maximumBlankLines)
      ?? defaults.maximumBlankLines
    self.lineLength =
      try container.decodeIfPresent(Int.self, forKey: .lineLength)
      ?? defaults.lineLength
    self.spacesBeforeEndOfLineComments =
      try container.decodeIfPresent(Int.self, forKey: .spacesBeforeEndOfLineComments)
      ?? defaults.spacesBeforeEndOfLineComments
    self.tabWidth =
      try container.decodeIfPresent(Int.self, forKey: .tabWidth)
      ?? defaults.tabWidth
    self.indentation =
      try container.decodeIfPresent(Indent.self, forKey: .indentation)
      ?? defaults.indentation
    self.respectsExistingLineBreaks =
      try container.decodeIfPresent(Bool.self, forKey: .respectsExistingLineBreaks)
      ?? defaults.respectsExistingLineBreaks
    self.lineBreakBeforeControlFlowKeywords =
      try container.decodeIfPresent(Bool.self, forKey: .lineBreakBeforeControlFlowKeywords)
      ?? defaults.lineBreakBeforeControlFlowKeywords
    self.lineBreakBeforeEachArgument =
      try container.decodeIfPresent(Bool.self, forKey: .lineBreakBeforeEachArgument)
      ?? defaults.lineBreakBeforeEachArgument
    self.lineBreakBeforeEachGenericRequirement =
      try container.decodeIfPresent(Bool.self, forKey: .lineBreakBeforeEachGenericRequirement)
      ?? defaults.lineBreakBeforeEachGenericRequirement
    self.lineBreakBetweenDeclarationAttributes =
      try container.decodeIfPresent(Bool.self, forKey: .lineBreakBetweenDeclarationAttributes)
      ?? defaults.lineBreakBetweenDeclarationAttributes
    self.prioritizeKeepingFunctionOutputTogether =
      try container.decodeIfPresent(Bool.self, forKey: .prioritizeKeepingFunctionOutputTogether)
      ?? defaults.prioritizeKeepingFunctionOutputTogether
    self.indentConditionalCompilationBlocks =
      try container.decodeIfPresent(Bool.self, forKey: .indentConditionalCompilationBlocks)
      ?? defaults.indentConditionalCompilationBlocks
    self.lineBreakAroundMultilineExpressionChainComponents =
      try container.decodeIfPresent(
        Bool.self,
        forKey: .lineBreakAroundMultilineExpressionChainComponents
      )
      ?? defaults.lineBreakAroundMultilineExpressionChainComponents
    self.spacesAroundRangeFormationOperators =
      try container.decodeIfPresent(
        Bool.self,
        forKey: .spacesAroundRangeFormationOperators
      )
      ?? defaults.spacesAroundRangeFormationOperators
    self.fileScopedDeclarationPrivacy =
      try container.decodeIfPresent(
        FileScopedDeclarationPrivacyConfiguration.self,
        forKey: .fileScopedDeclarationPrivacy
      )
      ?? defaults.fileScopedDeclarationPrivacy
    self.indentSwitchCaseLabels =
      try container.decodeIfPresent(Bool.self, forKey: .indentSwitchCaseLabels)
      ?? defaults.indentSwitchCaseLabels
    self.noAssignmentInExpressions =
      try container.decodeIfPresent(
        NoAssignmentInExpressionsConfiguration.self,
        forKey: .noAssignmentInExpressions
      )
      ?? defaults.noAssignmentInExpressions
    self.multiElementCollectionTrailingCommas =
      try container.decodeIfPresent(
        Bool.self,
        forKey: .multiElementCollectionTrailingCommas
      )
      ?? defaults.multiElementCollectionTrailingCommas

    self.reflowMultilineStringLiterals =
      try container.decodeIfPresent(MultilineStringReflowBehavior.self, forKey: .reflowMultilineStringLiterals)
      ?? defaults.reflowMultilineStringLiterals
    self.indentBlankLines =
      try container.decodeIfPresent(
        Bool.self,
        forKey: .indentBlankLines
      )
      ?? defaults.indentBlankLines

    // If the `rules` key is not present at all, default it to the built-in set
    // so that the behavior is the same as if the configuration had been
    // default-initialized. To get an empty rules dictionary, one can explicitly
    // set the `rules` key to `{}`.
    self.rules =
      try container.decodeIfPresent([String: Bool].self, forKey: .rules)
      ?? defaults.rules

    self.ruleSeverity =
    try container.decodeIfPresent([String: RuleSeverity].self, forKey: .ruleSeverity) ?? [:]
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    try container.encode(version, forKey: .version)
    try container.encode(maximumBlankLines, forKey: .maximumBlankLines)
    try container.encode(lineLength, forKey: .lineLength)
    try container.encode(spacesBeforeEndOfLineComments, forKey: .spacesBeforeEndOfLineComments)
    try container.encode(tabWidth, forKey: .tabWidth)
    try container.encode(indentation, forKey: .indentation)
    try container.encode(respectsExistingLineBreaks, forKey: .respectsExistingLineBreaks)
    try container.encode(lineBreakBeforeControlFlowKeywords, forKey: .lineBreakBeforeControlFlowKeywords)
    try container.encode(lineBreakBeforeEachArgument, forKey: .lineBreakBeforeEachArgument)
    try container.encode(lineBreakBeforeEachGenericRequirement, forKey: .lineBreakBeforeEachGenericRequirement)
    try container.encode(prioritizeKeepingFunctionOutputTogether, forKey: .prioritizeKeepingFunctionOutputTogether)
    try container.encode(indentConditionalCompilationBlocks, forKey: .indentConditionalCompilationBlocks)
    try container.encode(lineBreakBetweenDeclarationAttributes, forKey: .lineBreakBetweenDeclarationAttributes)
    try container.encode(
      lineBreakAroundMultilineExpressionChainComponents,
      forKey: .lineBreakAroundMultilineExpressionChainComponents
    )
    try container.encode(
      spacesAroundRangeFormationOperators,
      forKey: .spacesAroundRangeFormationOperators
    )
    try container.encode(fileScopedDeclarationPrivacy, forKey: .fileScopedDeclarationPrivacy)
    try container.encode(indentSwitchCaseLabels, forKey: .indentSwitchCaseLabels)
    try container.encode(noAssignmentInExpressions, forKey: .noAssignmentInExpressions)
    try container.encode(multiElementCollectionTrailingCommas, forKey: .multiElementCollectionTrailingCommas)
    try container.encode(reflowMultilineStringLiterals, forKey: .reflowMultilineStringLiterals)
    try container.encode(rules, forKey: .rules)
  }

  /// Returns the URL of the configuration file that applies to the given file or directory.
  public static func url(forConfigurationFileApplyingTo url: URL) -> URL? {
    // Despite the variable's name, this value might start out first as a file path (the path to a
    // source file being formatted). However, it will immediately have its basename removed in the
    // loop below, and from then on serve as a directory path only.
    var candidateDirectory = url.absoluteURL.standardized
    var isDirectory: ObjCBool = false
    if FileManager.default.fileExists(atPath: candidateDirectory.path, isDirectory: &isDirectory),
      isDirectory.boolValue
    {
      // If the path actually was a directory, append a fake basename so that the trimming code
      // below doesn't have to deal with the first-time special case.
      candidateDirectory.appendPathComponent("placeholder")
    }
    repeat {
      candidateDirectory.deleteLastPathComponent()
      let candidateFile = candidateDirectory.appendingPathComponent(".swift-format")
      if FileManager.default.isReadableFile(atPath: candidateFile.path) {
        return candidateFile
      }
    } while !candidateDirectory.isRoot

    return nil
  }
}

/// Configuration for the `FileScopedDeclarationPrivacy` rule.
public struct FileScopedDeclarationPrivacyConfiguration: Codable, Equatable {
  public enum AccessLevel: String, Codable {
    /// Private file-scoped declarations should be declared `private`.
    ///
    /// If a file-scoped declaration is declared `fileprivate`, it will be diagnosed (in lint mode)
    /// or changed to `private` (in format mode).
    case `private`

    /// Private file-scoped declarations should be declared `fileprivate`.
    ///
    /// If a file-scoped declaration is declared `private`, it will be diagnosed (in lint mode) or
    /// changed to `fileprivate` (in format mode).
    case `fileprivate`
  }

  /// The formal access level to use when encountering a file-scoped declaration with effective
  /// private access.
  public var accessLevel: AccessLevel = .private

  public init() {}
}

/// Configuration for the `NoAssignmentInExpressions` rule.
public struct NoAssignmentInExpressionsConfiguration: Codable, Equatable {
  /// A list of function names where assignments are allowed to be embedded in expressions that are
  /// passed as parameters to that function.
  public var allowedFunctions: [String] = [
    // Allow `XCTAssertNoThrow` because `XCTAssertNoThrow(x = try ...)` is clearer about intent than
    // `x = try XCTUnwrap(try? ...)` or force-unwrapped if you need to use the value `x` later on
    // in the test.
    "XCTAssertNoThrow"
  ]

  public init() {}
}

fileprivate extension URL {
  var isRoot: Bool {
    #if os(Windows)
    // FIXME: We should call into Windows' native check to check if this path is a root once https://github.com/swiftlang/swift-foundation/issues/976 is fixed.
    // https://github.com/swiftlang/swift-format/issues/844
    return self.pathComponents.count <= 1
    #else
    // On Linux, we may end up with an string for the path due to https://github.com/swiftlang/swift-foundation/issues/980
    // TODO: Remove the check for "" once https://github.com/swiftlang/swift-foundation/issues/980 is fixed.
    return self.path == "/" || self.path == ""
    #endif
  }
}

extension Configuration.RuleSeverity {
    var findingSeverity: Finding.Severity {
        switch self {
            case .warning: return .warning
            case .error: return .error
        }
    }
}
