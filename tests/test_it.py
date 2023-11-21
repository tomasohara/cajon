#! /usr/bin/env python

"""Tests for it"""

import pytest

@pytest.mark.xfail
def test_fubar():
    """Test xfails; note: needs function for xfail"""
    assert False, "Should fail"
