package com.example.formatter;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.function.Function;
import java.util.function.Predicate;

/**
 * Badly formatted copy of FormatterShowcase — run {@code mvn formatter:format} to fix it.
 *
 * <p>Every violation maps to a rule in Common-Standards-Eclipse-Code-Profile.xml:
 * <ul>
 *   <li>K&amp;R brace style: opening {@code {} on the same line instead of Allman next-line</li>
 *   <li>{@code else}, {@code catch} and {@code while} cuddled on the closing {@code }}</li>
 *   <li>Missing spaces before {@code (} in control-flow keywords</li>
 *   <li>Missing spaces around binary operators ({@code +}, {@code ==}, {@code ||}, …)</li>
 *   <li>Field declarations not column-aligned</li>
 *   <li>Lambda opening brace on its own line instead of end-of-line</li>
 * </ul>
 */
public class FormatterShowcaseUnformatted { // VIOLATION: { must be on next line (Allman style)

  /**
   * Severity levels used throughout this showcase.
   */
  public enum Severity { // VIOLATION: { must be on next line
    LOW, MEDIUM, HIGH, CRITICAL;

    /**
     * Returns {@code true} when action must be taken immediately.
     *
     * @return whether this severity is urgent
     */
    public boolean isUrgent() { // VIOLATION: { must be on next line
      return this==HIGH||this==CRITICAL; // VIOLATION: missing spaces around == and ||
    }
  }

  /**
   * Immutable event record.
   *
   * @param id unique identifier
   * @param message human-readable description
   * @param severity associated severity level
   */
  public record Event(long id, String message, Severity severity) { // VIOLATION: { must be on next line
    /**
     * Compact constructor — validates state.
     */
    public Event { // VIOLATION: { must be on next line
      if(message==null||message.isBlank()) { // VIOLATION: missing space before (, spaces around operators
        throw new IllegalArgumentException("message must not be blank");
      }
    }

    /**
     * Returns a formatted summary suitable for logging.
     *
     * @return formatted summary string
     */
    public String summary() { // VIOLATION: { must be on next line
      return "["+severity+"] #"+id+": "+message; // VIOLATION: missing spaces around +
    }
  }

  /**
   * Listener that reacts to {@link Event} objects.
   */
  public interface EventListener { // VIOLATION: { must be on next line
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
    default boolean accepts(Event event) { // VIOLATION: { must be on next line
      return true;
    }
  }

  // VIOLATION: fields not column-aligned (align_type_members_on_columns = true requires alignment)
  private final List<Event> events = new ArrayList<>();
  private final List<EventListener> listeners = new ArrayList<>();
  private long nextId = 1L;

  /**
   * Creates an empty {@code FormatterShowcaseUnformatted}.
   */
  public FormatterShowcaseUnformatted() { // VIOLATION: { must be on next line
  }

  /**
   * Emits an event and notifies all accepting listeners.
   *
   * @param message event message
   * @param severity event severity
   * @return the emitted {@link Event}
   */
  public Event emit(String message, Severity severity) { // VIOLATION: { must be on next line
    Event event = new Event(nextId++, message, severity);
    events.add(event);

    for(EventListener listener : listeners) { // VIOLATION: missing space before (, { on same line
      if(listener.accepts(event)) { // VIOLATION: missing space before (, { on same line
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
  public Severity classify(int score) { // VIOLATION: { must be on next line
    if(score<0||score>100) { // VIOLATION: missing space before (, spaces around operators
      throw new IllegalArgumentException("score must be in [0, 100], got: "+score);
    } else if(score<25) { // VIOLATION: else must be on new line; missing space before (
      return Severity.LOW;
    } else if(score<50) { // VIOLATION: else must be on new line
      return Severity.MEDIUM;
    } else if(score<75) { // VIOLATION: else must be on new line
      return Severity.HIGH;
    } else { // VIOLATION: else must be on new line
      return Severity.CRITICAL;
    }
  }

  /**
   * Returns a human-readable label for the given severity using a switch expression.
   *
   * @param severity the severity to label
   * @return label string
   */
  public String label(Severity severity) { // VIOLATION: { must be on next line
    return switch(severity) { // VIOLATION: missing space before (, { must be on next line
      case LOW -> "info";
      case MEDIUM -> "warning";
      case HIGH -> "error";
      case CRITICAL -> "fatal";
    };
  }

  /**
   * Reads all events and applies a transformation, demonstrating try-with-resources and multi-catch formatting.
   *
   * @param transform mapping function applied to each event message
   * @return list of transformed messages
   * @throws IOException if reading fails
   * @throws InterruptedException if the thread is interrupted while waiting
   */
  public List<String> readTransformed(Function<String, String> transform) throws IOException, InterruptedException { // VIOLATION: { must be on next line
    List<String> results = new ArrayList<>();

    try(var reader = new java.io.StringReader("placeholder"); var writer = new java.io.StringWriter()) { // VIOLATION: missing space before (, { on same line
      for(Event event : events) { // VIOLATION: missing space before (
        results.add(transform.apply(event.message()));
      }
    } catch(IllegalArgumentException|NullPointerException e) { // VIOLATION: catch must be on new line; missing spaces around |
      throw new IOException("Transformation failed: "+e.getMessage(), e); // VIOLATION: missing spaces around +
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
  public List<String> filterAndTransform(Predicate<Event> filter, Function<String, String> transform) { // VIOLATION: { must be on next line
    return events.stream().filter(filter).map(event ->
    { // VIOLATION: lambda { must be end-of-line, not on its own line
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
  public String arithmetic(int a, int b) { // VIOLATION: { must be on next line
    int sum = a+b; // VIOLATION: missing spaces around +
    int difference = a-b; // VIOLATION: missing spaces around -
    int product = a*b; // VIOLATION: missing spaces around *
    boolean equal = a==b; // VIOLATION: missing spaces around ==

    String relation = equal ? "equal" : (a>b ? "greater" : "less"); // VIOLATION: missing spaces around >

    return "sum="+sum+", diff="+difference+", prod="+product+", relation="+relation; // VIOLATION: missing spaces around +
  }

  /**
   * Demonstrates do-while formatting: {@code while} clause on a new line.
   *
   * @param limit upper bound (inclusive)
   * @return list of values from 0 to limit
   */
  public List<Integer> countUp(int limit) { // VIOLATION: { must be on next line
    List<Integer> values = new ArrayList<>();
    int i = 0;

    do { // VIOLATION: { must be on next line
      values.add(i++);
    } while(i<=limit); // VIOLATION: while must be on new line; missing space before (; spaces around <=

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
  public Map<String, Object> longSignatureExample(String firstParameter, String secondParameter, int thirdParameter) { // VIOLATION: { must be on next line
    int[] primes = {2, 3, 5, 7, 11, 13}; // VIOLATION: missing spaces inside array initializer braces
    int[][] matrix = {{1, 0}, {0, 1}}; // VIOLATION: missing spaces inside array initializer braces

    return Map.of("first", firstParameter, "second", secondParameter, "third", thirdParameter, "primeCount",
        primes.length, "matrixSize", matrix.length);
  }

  /**
   * Demonstrates {@code @formatter:off} / {@code @formatter:on} to protect a
   * manually aligned block from being reformatted.
   *
   * @return a fixed lookup table
   */
  public Map<String, Integer> manuallyAlignedTable() { // VIOLATION: { must be on next line
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
}
