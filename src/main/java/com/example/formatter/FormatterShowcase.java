package com.example.formatter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;

/**
 * Reference file demonstrating the Common Standards Eclipse Code Profile for Java.
 *
 * <p>Key rules exercised here:
 * <ul>
 *   <li>2-space indentation (spaces, not tabs)</li>
 *   <li>120-character line length</li>
 *   <li>Allman-style braces: opening brace on next line for types, methods, constructors and blocks</li>
 *   <li>{@code else}, {@code catch}, {@code finally} and {@code while} each start on a new line</li>
 *   <li>Compact {@code else if} (the {@code if} stays on the same line as {@code else})</li>
 *   <li>Spaces around all binary operators; no space after unary operators</li>
 *   <li>Lambdas: brace on end-of-line, arrow surrounded by spaces</li>
 *   <li>{@code @formatter:off} / {@code @formatter:on} regions are respected</li>
 * </ul>
 *
 * @author Common Standards
 * @version 1.0
 */
public class FormatterShowcase
{
  // -------------------------------------------------------------------------
  // Enum — brace on next line, each constant on its own line
  // -------------------------------------------------------------------------

  private final List<Event>         events    = new ArrayList<>();

  // -------------------------------------------------------------------------
  // Record — compact constructor, component list on one line (< 120 chars)
  // -------------------------------------------------------------------------
  private final List<EventListener> listeners = new ArrayList<>();

  // -------------------------------------------------------------------------
  // Interface with default method
  // -------------------------------------------------------------------------
  private long                      nextId    = 1L;

  // -------------------------------------------------------------------------
  // Fields
  // -------------------------------------------------------------------------

  /**
   * Creates an empty {@code FormatterShowcase}.
   */
  public FormatterShowcase()
  {
  }

  /**
   * Emits an event and notifies all accepting listeners.
   *
   * @param message event message
   * @param severity event severity
   * @return the emitted {@link Event}
   */
  public Event emit(String message, Severity severity)
  {
    Event event = new Event(nextId++, message, severity);
    events.add(event);

    for (EventListener listener : listeners)
    {
      if (listener.accepts(event))
      {
        listener.onEvent(event);
      }
    }

    return event;
  }

  /**
   * Classifies a raw score into a {@link Severity} level.
   * <p>
   * Demonstrates {@code if / else if / else} formatting.
   *
   * @param score a score in the range [0, 100]
   * @return the corresponding severity
   */
  public Severity classify(int score)
  {
    if (score < 0 || score > 100)
    {
      throw new IllegalArgumentException("score must be in [0, 100], got: " + score);
    }
    else if (score < 25)
    {
      return Severity.LOW;
    }
    else if (score < 50)
    {
      return Severity.MEDIUM;
    }
    else if (score < 75)
    {
      return Severity.HIGH;
    }
    else
    {
      return Severity.CRITICAL;
    }
  }

  // -------------------------------------------------------------------------
  // Constructor
  // -------------------------------------------------------------------------

  /**
   * Returns a human-readable label for the given severity using a switch expression.
   *
   * @param severity the severity to label
   * @return label string
   */
  public String label(Severity severity)
  {
    return switch (severity)
    {
      case LOW -> "info";
      case MEDIUM -> "warning";
      case HIGH -> "error";
      case CRITICAL -> "fatal";
    };
  }

  // -------------------------------------------------------------------------
  // Core methods — demonstrating control-flow formatting rules
  // -------------------------------------------------------------------------

  /**
   * Reads all events and applies a transformation, demonstrating try-with-resources and multi-catch formatting.
   *
   * @param transform mapping function applied to each event message
   * @return list of transformed messages
   * @throws IOException if reading fails
   * @throws InterruptedException if the thread is interrupted while waiting
   */
  public List<String> readTransformed(Function<String, String> transform) throws IOException, InterruptedException
  {
    List<String> results = new ArrayList<>();

    try (var reader = new java.io.StringReader("placeholder"); var writer = new java.io.StringWriter())
    {
      for (Event event : events)
      {
        results.add(transform.apply(event.message()));
      }
    }
    catch (IllegalArgumentException | NullPointerException e)
    {
      throw new IOException("Transformation failed: " + e.getMessage(), e);
    }

    return results;
  }

  /**
   * Demonstrates lambda formatting: brace on end-of-line, arrow surrounded by spaces.
   *
   * @param filter predicate used to filter events
   * @param transform function applied to matching event messages
   * @return filtered and transformed messages
   */
  public List<String> filterAndTransform(Predicate<Event> filter, Function<String, String> transform)
  {
    return events.stream().filter(filter).map(event -> {
      String raw = event.message();
      return transform.apply(raw);
    }).toList();
  }

  /**
   * Demonstrates operator spacing, ternary expression wrapping, and string concatenation.
   *
   * @param a first operand
   * @param b second operand
   * @return formatted arithmetic summary
   */
  public String arithmetic(int a, int b)
  {
    int sum = a + b;
    int difference = a - b;
    int product = a * b;
    boolean equal = a == b;

    String relation = equal ? "equal" : (a > b ? "greater" : "less");

    return "sum=" + sum + ", diff=" + difference + ", prod=" + product + ", relation=" + relation;
  }

  /**
   * Demonstrates do-while formatting: {@code while} clause on a new line.
   *
   * @param limit upper bound (inclusive)
   * @return list of values from 0 to limit
   */
  public List<Integer> countUp(int limit)
  {
    List<Integer> values = new ArrayList<>();
    int i = 0;
    do
    {
      values.add(i++);
    }
    while (i <= limit);

    return values;
  }

  /**
   * Demonstrates a long method signature that wraps at 120 characters, and an array initializer with end-of-line brace.
   *
   * @param firstParameter first input value
   * @param secondParameter second input value
   * @param thirdParameter third input value
   * @return map combining all three parameters
   */
  public Map<String, Object> longSignatureExample(String firstParameter, String secondParameter, int thirdParameter)
  {
    int[] primes = { 2, 3, 5, 7, 11, 13 };
    int[][] matrix = { { 1, 0 }, { 0, 1 } };

    return Map.of("first", firstParameter, "second", secondParameter, "third", thirdParameter, "primeCount",
        primes.length, "matrixSize", matrix.length);
  }

  /**
   * Demonstrates {@code @formatter:off} / {@code @formatter:on} to protect a
   * manually aligned block from being reformatted.
   *
   * @return a fixed lookup table
   */
  public Map<String, Integer> manuallyAlignedTable()
  {
    // @formatter:off
    return Map.of(
        "alpha",    1,
        "beta",     2,
        "gamma",    3,
        "delta",    4,
        "epsilon",  5
    );
    // @formatter:on
  }

  /**
   * Severity levels used throughout this showcase.
   */
  public enum Severity
  {
    LOW, MEDIUM, HIGH, CRITICAL;

    /**
     * Returns {@code true} when action must be taken immediately.
     *
     * @return whether this severity is urgent
     */
    public boolean isUrgent()
    {
      return this == HIGH || this == CRITICAL;
    }
  }

  /**
   * Listener that reacts to {@link Event} objects.
   */
  public interface EventListener
  {
    /**
     * Called when an event is emitted.
     *
     * @param event the emitted event
     */
    void onEvent(Event event);

    /**
     * Optional filter — by default accepts all events.
     *
     * @param event the candidate event
     * @return {@code true} if the event should be delivered
     */
    default boolean accepts(Event event)
    {
      return true;
    }
  }

  /**
   * Immutable event record.
   *
   * @param id unique identifier
   * @param message human-readable description
   * @param severity associated severity level
   */
  public record Event(long id, String message, Severity severity)
  {
    /**
     * Compact constructor — validates state.
     */
    public Event
    {
      if (message == null || message.isBlank())
      {
        throw new IllegalArgumentException("message must not be blank");
      }
    }

    /**
     * Returns a formatted summary suitable for logging.
     *
     * @return formatted summary string
     */
    public String summary()
    {
      return "[" + severity + "] #" + id + ": " + message;
    }
  }
}
