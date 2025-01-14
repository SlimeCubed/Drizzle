using System;

namespace Drizzle.Lingo.Runtime;

public struct LingoRect : IEquatable<LingoRect>, ILingoVector
{
    public LingoNumber left;
    public LingoNumber top;
    public LingoNumber right;
    public LingoNumber bottom;

    public LingoNumber width => right - left;
    public LingoNumber height => bottom - top;

    int ILingoVector.CountElems => 4;

    public LingoNumber this[int index]
    {
        get => index switch
        {
            1 => left,
            2 => top,
            3 => right,
            4 => bottom,
            _ => throw new IndexOutOfRangeException()
        };
        set
        {
            switch(index)
            {
                case 1: left = value; break;
                case 2: top = value; break;
                case 3: right = value; break;
                case 4: bottom = value; break;
                default: throw new IndexOutOfRangeException();
            }
        }
    }

    public LingoNumber this[LingoNumber index]
    {
        get => this[(int)index];
        set => this[(int)index] = value;
    }

    object ILingoVector.this[int index] => this[index];

    private LingoRect(LingoNumber all) : this(all, all, all, all)
    {
    }

    public LingoRect(LingoNumber left, LingoNumber top, LingoNumber right, LingoNumber bottom)
    {
        this.left = left;
        this.top = top;
        this.right = right;
        this.bottom = bottom;
    }

    // Yes, constructing a rect out of points rounds them.
    public LingoRect(LingoPoint lt, LingoPoint rb)
        : this(lt.loch.integer, lt.locv.integer, rb.loch.integer, rb.locv.integer)
    {
    }

    public static LingoRect operator +(LingoRect a, LingoRect b)
    {
        return new(
            a.left + b.left,
            a.top + b.top,
            a.right + b.right,
            a.bottom + b.bottom);
    }

    public static LingoRect operator -(LingoRect a, LingoRect b)
    {
        return new(
            a.left - b.left,
            a.top - b.top,
            a.right - b.right,
            a.bottom - b.bottom);
    }

    public static LingoRect operator *(LingoRect a, LingoRect b)
    {
        return new(
            a.left * b.left,
            a.top * b.top,
            a.right * b.right,
            a.bottom * b.bottom);
    }

    public static LingoRect operator /(LingoRect a, LingoRect b)
    {
        return new(
            a.left / b.left,
            a.top / b.top,
            a.right / b.right,
            a.bottom / b.bottom);
    }

    public static LingoRect operator %(LingoRect a, LingoRect b)
    {
        return new(
            a.left % b.left,
            a.top % b.top,
            a.right % b.right,
            a.bottom % b.bottom);
    }

    public static LingoRect operator +(LingoRect a, LingoNumber b) => a + new LingoRect(b);
    public static LingoRect operator +(LingoNumber a, LingoRect b) => new LingoRect(a) + b;
    public static LingoRect operator -(LingoRect a, LingoNumber b) => a - new LingoRect(b);
    public static LingoRect operator -(LingoNumber a, LingoRect b) => new LingoRect(a) - b;
    public static LingoRect operator *(LingoRect a, LingoNumber b) => a * new LingoRect(b);
    public static LingoRect operator *(LingoNumber a, LingoRect b) => new LingoRect(a) * b;
    public static LingoRect operator /(LingoRect a, LingoNumber b) => a / new LingoRect(b);
    public static LingoRect operator /(LingoNumber a, LingoRect b) => new LingoRect(a) / b;
    public static LingoRect operator %(LingoRect a, LingoNumber b) => a % new LingoRect(b);
    public static LingoRect operator %(LingoNumber a, LingoRect b) => new LingoRect(a) % b;

    public LingoRect intersect(LingoRect other)
    {
        LingoNumber nLeft = left < other.left ? other.left : left;
        LingoNumber nRight = right > other.right ? other.right : right;
        LingoNumber nUp = top < other.top ? other.top : top;
        LingoNumber nDown = bottom > other.bottom ? other.bottom : bottom;
        return new LingoRect(nLeft, nUp, nRight, nDown);
    }
    public bool Equals(LingoRect other)
    {
        return left == other.left && top == other.top && right == other.right && bottom == other.bottom;
    }

    public override bool Equals(object? obj)
    {
        return obj is LingoRect other && Equals(other);
    }

    public override int GetHashCode()
    {
        return HashCode.Combine(left, top, right, bottom);
    }

    public static bool operator ==(LingoRect left, LingoRect right)
    {
        return left.Equals(right);
    }

    public static bool operator !=(LingoRect left, LingoRect right)
    {
        return !left.Equals(right);
    }

    public override string ToString() => $"rect({left}, {top}, {right}, {bottom})";
}
